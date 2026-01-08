import Foundation

/// The current permission mode of Claude Code.
///
/// This indicates what level of permissions Claude Code is operating with.
public enum PermissionMode: String, Decodable {
    /// The default permission mode where Claude asks for permission.
    case `default`
    /// Plan mode where Claude Code is planning actions without executing.
    case plan
    /// Mode where file edits are automatically accepted.
    case acceptEdits
    /// Mode where all permissions are bypassed (dangerous operations allowed).
    case bypassPermissions
}

/// The source that triggered a session start.
///
/// Indicates how the current session was initiated.
public enum SessionStartSource: String, Decodable {
    /// A fresh new session was started.
    case startup
    /// The session was resumed from a previous state.
    case resume
    /// The session was started after clearing the previous session.
    case clear
    /// The session was started after compacting the conversation.
    case compact
}

/// The reason why a session ended.
///
/// Indicates what caused the session to terminate.
public enum SessionEndReason: String, Decodable {
    /// The session was cleared by the user.
    case clear
    /// The user logged out.
    case logout
    /// The user exited from the prompt input.
    case promptInputExit = "prompt_input_exit"
    /// The session ended for another reason.
    case other
}

/// The base protocol for all hook input types.
///
/// All hooks receive JSON input via stdin containing common session information.
/// Each hook type has additional event-specific fields.
public protocol StdinInput: Decodable {
    /// The unique identifier for the current session.
    var sessionID: UUID { get }
    /// The path to the conversation transcript file (JSONL format).
    ///
    /// The transcript contains everything shown during the session,
    /// including hidden information. Each line is an individual JSON object.
    var transcriptPath: URL { get }
    /// The current working directory when the hook is invoked.
    var cwd: URL { get }
    /// The current permission mode of Claude Code.
    var permissionMode: PermissionMode { get }
    /// The name of the hook event that triggered this invocation.
    var hookEventName: Event { get }
}

/// The input received for a `PreToolUse` hook.
///
/// Called before a tool is executed. Use this hook for validation,
/// permission control, or input modification.
public struct PreToolUseInput<Input: Decodable>: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`PreToolUse`).
    public var hookEventName: Event
    /// The name of the tool being called (e.g., "Bash", "Write", "Read").
    public var toolName: String
    /// The tool's input parameters.
    ///
    /// For example, for a Bash tool this would contain the `command` field.
    public var toolInput: Input?

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

/// The input received for a `PostToolUse` hook.
///
/// Called after a tool is executed. Use this hook for logging,
/// auditing, or adding additional context based on results.
public struct PostToolUseInput<Input: Decodable, Response: Decodable>: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`PostToolUse`).
    public var hookEventName: Event
    /// The name of the tool that was executed.
    public var toolName: String
    /// The tool's input parameters that were used.
    public var toolInput: Input?
    /// The result returned by the tool execution.
    public var toolResponse: Response?

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

/// The input received for a `Notification` hook.
///
/// Called when Claude Code sends a notification to the user.
/// This hook is purely informational and cannot block Claude Code behavior.
public struct NotificationInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`Notification`).
    public var hookEventName: Event
    /// The notification message content.
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

/// The input received for a `UserPromptSubmit` hook.
///
/// Called when the user submits a prompt. This hook can validate,
/// block, or add context to user prompts before they are processed.
/// Output from this hook is added as context for Claude.
public struct UserPromptSubmitInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`UserPromptSubmit`).
    public var hookEventName: Event
    /// The prompt text submitted by the user.
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

/// The input received for a `Stop` hook.
///
/// Called when Claude Code is about to stop. Use this hook to control
/// whether Claude should continue or perform cleanup actions.
public struct StopInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`Stop`).
    public var hookEventName: Event
    /// Whether Claude Code is already continuing as a result of a stop hook.
    ///
    /// Check this value to prevent Claude Code from running indefinitely.
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

/// The input received for a `SubagentStop` hook.
///
/// Called when a subagent (spawned by the Task tool) is about to stop.
/// Use this hook to validate task completion or perform cleanup.
public struct SubagentStopInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`SubagentStop`).
    public var hookEventName: Event
    /// Whether a stop hook is already active for this subagent.
    ///
    /// Check this value to prevent infinite loops.
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

/// The input received for a `SessionStart` hook.
///
/// Called when a new session begins. Use this hook to initialize
/// session-specific resources or add initial context for Claude.
/// Output from this hook is added as context for Claude.
public struct SessionStartInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`SessionStart`).
    public var hookEventName: Event
    /// How the session was started.
    ///
    /// Can be `startup` (fresh start), `resume` (resumed from previous),
    /// `clear` (after clearing), or `compact` (after compacting).
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

/// The input received for a `SessionEnd` hook.
///
/// Called when a session is ending. Use this hook for cleanup,
/// logging, or saving session data.
public struct SessionEndInput: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`SessionEnd`).
    public var hookEventName: Event
    /// The reason why the session is ending.
    ///
    /// Can be `clear`, `logout`, `promptInputExit`, or `other`.
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

/// The input received for a `PermissionRequest` hook.
///
/// Called when Claude Code requests permission for an action.
/// Use this hook to automatically allow or deny permission requests.
public struct PermissionRequestInput<Input: Decodable>: StdinInput {
    /// The unique identifier for the current session.
    public var sessionID: UUID
    /// The path to the conversation transcript file (JSONL format).
    public var transcriptPath: URL
    /// The current working directory when the hook is invoked.
    public var cwd: URL
    /// The current permission mode of Claude Code.
    public var permissionMode: PermissionMode
    /// The name of the hook event (`PermissionRequest`).
    public var hookEventName: Event
    /// The name of the tool being requested.
    public var toolName: String
    /// The tool's input parameters for the permission request.
    public var toolInput: Input?

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
