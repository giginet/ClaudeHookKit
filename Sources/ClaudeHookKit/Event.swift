import Foundation

/// Represents the type of hook event in Claude Code.
///
/// Each event corresponds to a specific point in the Claude Code lifecycle
/// where hooks can be executed.
public enum Event: String, Codable, Sendable {
    /// Called before a tool is executed.
    case preToolUse = "PreToolUse"
    /// Called after a tool is executed.
    case postToolUse = "PostToolUse"
    /// Called when Claude Code sends a notification.
    case notification = "Notification"
    /// Called when the user submits a prompt.
    case userPromptSubmit = "UserPromptSubmit"
    /// Called when Claude Code stops.
    case stop = "Stop"
    /// Called when a subagent stops.
    case subagentStop = "SubagentStop"
    /// Called when a session starts.
    case sessionStart = "SessionStart"
    /// Called when a session ends.
    case sessionEnd = "SessionEnd"
    /// Called when a permission is requested.
    case PermissionRequest = "PermissionRequest"
}
