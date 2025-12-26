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
    var sessionID: UUID { get }
    var transcriptPath: URL { get }
    var cwd: URL { get }
    var permissionMode: PermissionMode { get }
    var hookEventName: Event { get }
}

public protocol ToolInput: Decodable { }

public struct PreToolUseInput<Input: ToolInput>: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: Input

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case toolName = "tool_name"
        case toolInput = "tool_input"
    }
}

public protocol ToolResponse: Decodable { }

public struct PostToolUseInput<Input: ToolInput, Response: ToolResponse>: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var toolName: String
    public var toolInput: Input
    public var toolResponse: Response

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case toolName = "tool_name"
        case toolInput = "tool_input"
        case toolResponse = "tool_response"
    }
}

public struct NotificationInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var message: String

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case message
    }
}

public struct UserPromptSubmitInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var prompt: String

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case prompt
    }
}

public struct StopInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case stopHookActive = "stop_hook_active"
    }
}

public struct SubagentStopInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var stopHookActive: Bool

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case stopHookActive = "stop_hook_active"
    }
}

public struct SessionStartInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var source: SessionStartSource

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case source
    }
}

public struct SessionEndInput: StdinInput {
    public var sessionID: UUID
    public var transcriptPath: URL
    public var cwd: URL
    public var permissionMode: PermissionMode
    public var hookEventName: Event
    public var reason: SessionEndReason

    private enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case transcriptPath = "transcript_path"
        case cwd
        case permissionMode = "permission_mode"
        case hookEventName = "hook_event_name"
        case reason
    }
}
