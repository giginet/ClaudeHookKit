import Foundation
import Logging

/// The result returned from a hook invocation.
///
/// Hooks can return either an exit code or JSON output to communicate
/// their result to Claude Code.
public enum HookResult<Output: StdoutOutput> {
    /// Represents the exit status of a hook.
    public enum ExitCodeStatus {
        /// The hook completed successfully (exit code 0).
        case success
        /// The hook encountered a blocking error (exit code 2).
        ///
        /// This will block the action that triggered the hook.
        case blockingError
        /// The hook encountered a non-blocking error with a custom exit code.
        ///
        /// - Parameter exitCode: The exit code to return. Must not be 2 (use `blockingError` instead).
        case nonBlockingError(exitCode: Int32)
    }
    /// Return an exit code without any JSON output.
    case exitCode(ExitCodeStatus)
    /// Return JSON output to stdout.
    case jsonOutput(Output)
}

/// The base protocol for all Claude Code hooks.
///
/// Implement this protocol to create a custom hook. For convenience,
/// use one of the specialized hook protocols like ``PreToolUseHook``
/// or ``NotificationHook`` which provide type-safe input/output types.
public protocol Hook {
    /// The input type received from Claude Code.
    associatedtype Input: StdinInput
    /// The output type returned to Claude Code.
    associatedtype Output: StdoutOutput

    /// Invoked when the hook is triggered.
    ///
    /// - Parameters:
    ///   - input: The input data from Claude Code.
    ///   - context: The execution context containing logger and environment information.
    /// - Returns: The result of the hook invocation.
    static func invoke(input: Input, context: Context) -> HookResult<Output>

    static var logMode: LogMode { get }
}

/// A placeholder type for hooks that don't use tool input.
public struct NeverToolInput: Decodable {}

/// A placeholder type for hooks that don't use tool response.
public struct NeverToolResponse: Decodable {}

/// A hook that is called before a tool is executed.
///
/// Use this hook to:
/// - Allow or deny tool execution
/// - Modify tool input before execution
/// - Add custom permission logic
///
/// ## Example
/// ```swift
/// @main
/// struct MyPreToolHook: PreToolUseHook {
///     typealias ToolInput = BashToolInput
///     typealias UpdatedInput = Empty
///
///     static func invoke(input: PreToolUseInput<BashToolInput>, context: Context) -> HookResult<PreToolUseOutput<Empty>> {
///         // Your logic here
///         return .exitCode(.success)
///     }
/// }
/// ```
public protocol PreToolUseHook: Hook
where
    Input == PreToolUseInput<ToolInput>,
    Output == PreToolUseOutput<UpdatedInput>
{
    /// The type representing the tool's input parameters.
    associatedtype ToolInput: Decodable
    /// The type for updated input if modifying the tool input.
    associatedtype UpdatedInput: Encodable & Sendable
}

/// A hook that is called after a tool is executed.
///
/// Use this hook to:
/// - Inspect tool results
/// - Add additional context based on results
/// - Log or audit tool usage
public protocol PostToolUseHook: Hook
where
    Input == PostToolUseInput<ToolInput, ToolResponse>,
    Output == PostToolUseOutput
{
    /// The type representing the tool's input parameters.
    associatedtype ToolInput: Decodable
    /// The type representing the tool's response.
    associatedtype ToolResponse: Decodable
}

/// A hook that is called when Claude Code sends a notification.
///
/// Use this hook to:
/// - Play sounds or show system notifications
/// - Log notifications
/// - Forward notifications to external services
public protocol NotificationHook: Hook
where
    Input == NotificationInput,
    Output == NotificationOutput
{
}

/// A hook that is called when the user submits a prompt.
///
/// Use this hook to:
/// - Validate or filter user prompts
/// - Add context to prompts
/// - Log user interactions
public protocol UserPromptSubmitHook: Hook
where
    Input == UserPromptSubmitInput,
    Output == UserPromptSubmitOutput
{
}

/// A hook that is called when Claude Code stops.
///
/// Use this hook to:
/// - Perform cleanup actions
/// - Save state
/// - Block the stop action if needed
public protocol StopHook: Hook
where
    Input == StopInput,
    Output == StopOutput
{
}

/// A hook that is called when a subagent stops.
///
/// Use this hook to:
/// - Track subagent lifecycle
/// - Perform cleanup for subagent resources
public protocol SubagentStopHook: Hook
where
    Input == SubagentStopInput,
    Output == SubagentStopOutput
{
}

/// A hook that is called when a session starts.
///
/// Use this hook to:
/// - Initialize session-specific resources
/// - Set up logging
/// - Add initial context
public protocol SessionStartHook: Hook
where
    Input == SessionStartInput,
    Output == SessionStartOutput
{
}

/// A hook that is called when a session ends.
///
/// Use this hook to:
/// - Clean up session resources
/// - Save session data
/// - Log session summary
public protocol SessionEndHook: Hook
where
    Input == SessionEndInput,
    Output == SessionEndOutput
{
}

/// A hook that is called when a permission is requested.
///
/// Use this hook to:
/// - Automatically allow or deny permission requests
/// - Modify input parameters before execution
/// - Implement custom permission logic
public protocol PermissionRequestHook: Hook
where
    Input == PermissionRequestInput<ToolInput>,
    Output == PermissionRequestOutput<UpdatedInput>
{
    /// The type representing the tool's input parameters.
    associatedtype ToolInput: Decodable
    /// The type for updated input if modifying the permission request input.
    associatedtype UpdatedInput: Encodable & Sendable
}

/// An empty type used as a placeholder for unused generic parameters.
///
/// Use this type when a hook doesn't need to provide tool input,
/// tool response, or updated input.
public struct Empty: Codable, Sendable {
}
