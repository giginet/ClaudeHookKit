import Foundation

public enum Event: String, Codable {
    case preToolUse = "PreToolUse"
    case postToolUse = "PostToolUse"
    case notification = "Notification"
    case userPromptSubmit = "UserPromptSubmit"
    case stop = "Stop"
    case subagentStop = "SubagentStop"
    case sessionStart = "SessionStart"
    case sessionEnd = "SessionEnd"
}
