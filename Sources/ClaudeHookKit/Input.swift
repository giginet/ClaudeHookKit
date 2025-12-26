import Foundation

public enum PermissionMode: String, Decodable {
    case `default`
    case plan
    case acceptEdits = "accept_edits"
    case bypassPermissions = "bypass_permissions"
}

public enum SessionStartSource: String, Decodable {
    case startup
    case resume
    case clear
    case compact
}

public enum SessionEndReason: String, Decodable {
    case clear
    case logout
    case promptInputExit = "prompt_input_exit"
    case other
}

public protocol StdinInput: Decodable {
    var sessionID: String { get }
    var transcriptPath: URL { get }
    var cwd: URL { get }
    var permissionMode: PermissionMode { get }
    var hookEventName: Event { get }
}

public protocol ToolInput: Decodable { }

public struct PreToolUseInput<Input: ToolInput>: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: Input
}

public protocol ToolResponse: Decodable { }

public struct PostToolUseInput<Input: ToolInput, Response: ToolResponse>: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: Input
    public var toolResponse: Response
}

public struct NotificationInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var message: String
}

public struct UserPromptSubmitInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var prompt: String
}

public struct StopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool
}

public struct SubagentStopInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool
}

public struct SessionStartInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var source: SessionStartSource
}

public struct SessionEndInput: StdinInput {
    public var sessionID: String
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var reason: SessionEndReason
}
