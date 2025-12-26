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

// MARK: - StdinInput Protocol

public protocol StdinInput {
    var sessionID: String { get }
    var transcriptPath: URL { get }
    var cwd: URL { get }
    var permissionMode: PermissionMode { get }
    var hookEventName: Event { get }
}
// MARK: - PreToolUse Input

public protocol ToolInput: Decodable { }

/// Input received before a tool is executed
public struct PreToolUseInput<Input: ToolInput>: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: ToolInput
}

// MARK: - PostToolUse Input

public protocol ToolResponse: Decodable { }

/// Input received after a tool has completed successfully
public struct PostToolUseInput<Input: ToolInput, Response: ToolResponse>: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: ToolInput
    public var toolResponse: ToolResponse
}

// MARK: - Notification Input

/// Input received when Claude Code sends a notification
public struct NotificationInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var message: String
}

// MARK: - UserPromptSubmit Input

/// Input received when a user submits a prompt (before Claude processes it)
public struct UserPromptSubmitInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var prompt: String
}

// MARK: - Stop Input

/// Input received when Claude stops
public struct StopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool
}

// MARK: - SubagentStop Input

/// Input received when a subagent stops
public struct SubagentStopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool
}

// MARK: - SessionStart Input

/// Input received when a session starts
public struct SessionStartInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var source: SessionStartSource
}

// MARK: - SessionEnd Input

/// Input received when a session ends
public struct SessionEndInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var reason: SessionEndReason
}
