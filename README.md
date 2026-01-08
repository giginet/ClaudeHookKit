# ClaudeHookKit

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/giginet/ClaudeHookKit/tests.yml?style=flat-square&logo=github)
![Swift 6.2](https://img.shields.io/badge/Swift-6.2-FA7343?logo=swift&style=flat-square)
[![Xcode 26.2](https://img.shields.io/badge/Xcode-26.2-16C5032a?style=flat-square&logo=xcode&link=https%3A%2F%2Fdeveloper.apple.com%2Fxcode%2F)](https://developer.apple.com/xcode/)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-green?logo=swift&style=flat-square)](https://swift.org/package-manager/)
![Platforms](https://img.shields.io/badge/Platform-macOS-lightgray?logo=apple&style=flat-square)
[![License](https://img.shields.io/badge/License-MIT-darkgray?style=flat-square)](https://github.com/giginet/ClaudeHookKit/blob/main/LICENSE.md)

A Swift framework for building [Claude Code Hooks](https://code.claude.com/docs/en/hooks) with type-safe APIs.

## Overview

ClaudeHookKit provides a type-safe way to implement Claude Code hooks in Swift. It handles JSON serialization/deserialization, input validation, and output formatting, allowing you to focus on your hook logic.

## Requirements

- Swift 6.2+
- macOS 14+

## Usage

ClaudeHookKit uses the `@main` attribute to define the entry point. Simply add `@main` to your hook struct and implement the `static func invoke` method:

```swift
@main
struct MyHook: NotificationHook {
    static func invoke(input: NotificationInput, context: Context) -> HookResult<NotificationOutput> {
        // Your hook logic here
        return .exitCode(.success)
    }
}
```

The `Hook` protocol extension provides a `static func main()` that handles:
- Reading JSON input from stdin
- Decoding input to the appropriate type
- Calling your `invoke` method
- Outputting results (exit code or JSON)
- Error handling

### Basic Example

Here's a simple example of a `Notification` hook that plays a sound when Claude Code sends a notification:

```swift
import ClaudeHookKit
import Foundation

@main
struct NotificationSoundPlayer: NotificationHook {
    static func invoke(input: NotificationInput, context: Context) -> HookResult<NotificationOutput> {
        // Play the default system sound
        let task = Process()
        task.executableURL = URL(filePath: "/usr/bin/afplay")
        task.arguments = ["/System/Library/Sounds/Glass.aiff"]
        try? task.run()

        return .exitCode(.success)
    }
}
```

### Use Decodable ToolInput

You can define custom `Decodable` structs to represent the input for specific tools. Here's an example of a hook that blocks dangerous bash commands:

```swift
import ClaudeHookKit

struct BashToolInput: Decodable {
    let command: String
    let description: String
}

@main
struct DangerousCommandBlocker: PreToolUseHook {
    typealias ToolInput = BashToolInput
    typealias UpdatedInput = Empty

    static func invoke(input: PreToolUseInput<BashToolInput>, context: Context) -> HookResult<PreToolUseOutput<Empty>> {
        let dangerousCommands = ["rm -rf", "sudo rm", "mkfs", "> /dev/"]

        for dangerous in dangerousCommands {
            if input.toolInput.command.contains(dangerous) {
                return .jsonOutput(
                    PreToolUseOutput(
                        hookSpecificOutput: .init(
                            permissionDecision: .deny,
                            permissionDecisionReason: "Blocked dangerous command: \(dangerous)",
                            updatedInput: nil
                        )
                    )
                )
            }
        }

        return .exitCode(.success)
    }
}
```

### Auto-approve Documentation Files

Here's an example of a `PreToolUse` hook that auto-approves Read tool calls for documentation files:

```swift
import ClaudeHookKit

struct ReadToolInput: Decodable {
    let filePath: String

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}

@main
struct DocumentationAutoApprover: PreToolUseHook {
    typealias ToolInput = ReadToolInput
    typealias UpdatedInput = Empty

    static func invoke(input: PreToolUseInput<ReadToolInput>, context: Context) -> HookResult<PreToolUseOutput<Empty>> {
        let documentationExtensions = [".md", ".mdx", ".txt", ".json"]

        // Check if file is a documentation file
        for ext in documentationExtensions {
            if input.toolInput.filePath.hasSuffix(ext) {
                return .jsonOutput(
                    PreToolUseOutput(
                        suppressOutput: true,
                        hookSpecificOutput: .init(
                            permissionDecision: .allow,
                            permissionDecisionReason: "Documentation file auto-approved",
                            updatedInput: nil
                        )
                    )
                )
            }
        }

        // Let the normal permission flow proceed
        return .exitCode(.success)
    }
}
```

### Supported Hook Types

ClaudeHookKit supports all Claude Code hook events:

| Hook Protocol | Event | Description |
|---------------|-------|-------------|
| `PreToolUseHook` | `PreToolUse` | Called before a tool is executed |
| `PostToolUseHook` | `PostToolUse` | Called after a tool is executed |
| `NotificationHook` | `Notification` | Called when Claude Code sends a notification |
| `UserPromptSubmitHook` | `UserPromptSubmit` | Called when the user submits a prompt |
| `StopHook` | `Stop` | Called when Claude Code stops |
| `SubagentStopHook` | `SubagentStop` | Called when a subagent stops |
| `SessionStartHook` | `SessionStart` | Called when a session starts |
| `SessionEndHook` | `SessionEnd` | Called when a session ends |
| `PermissionRequestHook` | `PermissionRequest` | Called when a permission is requested |

### Hook Results

Hooks can return two types of results. See [Hook Output](https://code.claude.com/docs/en/hooks#hook-output) section.

#### Exit Code Results

```swift
return .exitCode(.success)           // Exit with success (exit code 0)
return .exitCode(.blockingError)     // Block the action (exit code 2)
return .exitCode(.nonBlockingError(1)) // Non-blocking error with custom exit code
```

#### JSON Output Results

For hooks that need to return structured output:

```swift
return .jsonOutput(
    PreToolUseOutput(
        hookSpecificOutput: .init(
            permissionDecision: .deny,
            permissionDecisionReason: "Reason for denying",
            updatedInput: nil
        )
    )
)
```

### Debug and Logging

You can use the logger in the `Context` to log messages for debugging:

```swift
static func invoke(input: Input, context: Context) -> HookResult<Output> {
    // Log a message
    context.logger.debug("Hook invoked with input: \(input)")

    return .exitCode(.success)
}
```

> [!WARNING]
> Do not use `print` to output logs, as it may interfere with the hook's JSON output. Use the provided logger instead.

#### Configuring Log Output

By default, logging is disabled. To enable logging to a file, override the `logMode` property in your hook:

```swift
@main
struct MyHook: NotificationHook {
    static var logMode: LogMode {
        .enabled(URL(filePath: "/tmp/my-hook.log"))
    }

    static func invoke(input: NotificationInput, context: Context) -> HookResult<NotificationOutput> {
        context.logger.debug("Hook invoked")
        return .exitCode(.success)
    }
}
```

The `LogMode` enum has two cases:
- `.disabled` - Logging is disabled (default)
- `.enabled(URL)` - Logging is enabled, writing to the specified file URL

You can also use the standard debug logger of Claude Code. See [Debugging](https://code.claude.com/docs/en/hooks#debugging) section of the official documentation.

### Context

The `Context` object provides access to environment information:

```swift
static func invoke(input: Input, context: Context) -> HookResult<Output> {
    // Access the project directory
    if let projectDir = context.projectDirectoryPath {
        // ...
    }

    // Use the logger
    context.logger.debug("Processing hook...")

    return .exitCode(.success)
}
```

### Configuring Hooks in Claude Code

After building your hook executable, configure it in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/your/hook"
          }
        ]
      }
    ]
  }
}
```

## License

MIT License
