import Foundation

// MARK: - Permission Mode

public enum PermissionMode: String {
    case `default`
    case plan
    case acceptEdits
    case bypassPermissions
}

// MARK: - Session Start Source

public enum SessionStartSource: String {
    case startup
    case resume
    case clear
    case compact
}

// MARK: - Session End Reason

public enum SessionEndReason: String {
    case clear
    case logout
    case promptInputExit = "prompt_input_exit"
    case other
}

// MARK: - Hook Event Name

public enum HookEventName: String {
    case preToolUse = "PreToolUse"
    case postToolUse = "PostToolUse"
    case notification = "Notification"
    case userPromptSubmit = "UserPromptSubmit"
    case stop = "Stop"
    case subagentStop = "SubagentStop"
    case sessionStart = "SessionStart"
    case sessionEnd = "SessionEnd"
}

// MARK: - StdinInput Protocol

public protocol StdinInput {
    var sessionID: String { get }
    var transcriptPath: URL { get }
    var currentWorkingDirectory: URL { get }
    var permissionMode: PermissionMode { get }
    var hookEventName: HookEventName { get }
}

// MARK: - PreToolUse Input

/// Input received before a tool is executed
public struct PreToolUseInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    public var toolName: String
    /// Tool input as raw JSON. The schema varies depending on the tool (Write, Read, Bash, etc.)
    public var toolInput: [String: Any]
}

// MARK: - PostToolUse Input

/// Input received after a tool has completed successfully
public struct PostToolUseInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    public var toolName: String
    /// Tool input as raw JSON. The schema varies depending on the tool.
    public var toolInput: [String: Any]
    /// Tool response as raw JSON. The schema varies depending on the tool.
    public var toolResponse: [String: Any]
}

// MARK: - Notification Input

/// Input received when Claude Code sends a notification
public struct NotificationInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    public var message: String
}

// MARK: - UserPromptSubmit Input

/// Input received when a user submits a prompt (before Claude processes it)
public struct UserPromptSubmitInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    public var prompt: String
}

// MARK: - Stop Input

/// Input received when Claude stops
public struct StopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    /// Whether a hook is already running
    public var stopHookActive: Bool
}

// MARK: - SubagentStop Input

/// Input received when a subagent stops
public struct SubagentStopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    /// Whether a hook is already running
    public var stopHookActive: Bool
}

// MARK: - SessionStart Input

/// Input received when a session starts
public struct SessionStartInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    /// The source of the session start
    public var source: SessionStartSource
}

// MARK: - SessionEnd Input

/// Input received when a session ends
public struct SessionEndInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: HookEventName
    /// The reason the session ended
    public var reason: SessionEndReason
}
