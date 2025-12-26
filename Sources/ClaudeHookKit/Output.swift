import Foundation

public protocol StdoutOutput: Encodable {
    var `continue`: Bool { get }
    var stopReason: String { get }
    var suppressOutput: Bool { get }
    var systemMessage: String { get }
}

public protocol UpdatedInput: Encodable { }

public struct PreToolUseOutput<Input: UpdatedInput>: StdoutOutput {
    public enum PermissionDecision: Encodable {
        case allow
        case deny
        case ask
    }
    
    public struct HookSpecificOutput: Encodable {
        public var hookEventName: Event
        public var permissionDecision: PermissionDecision
        public var permissionDecisionReason: String
        public var updatedInput: Input
    }
    
    public var `continue`: Bool
    public var stopReason: String
    public var suppressOutput: Bool
    public var systemMessage: String
    public var hookSpecificOutput: HookSpecificOutput
    
    public init(
        continue: Bool = true,
        stopReason: String,
        suppressOutput: Bool = true,
        systemMessage: String,
        hookSpecificOutput: HookSpecificOutput
    ) {
        self.continue = `continue`
        self.stopReason = stopReason
        self.suppressOutput = suppressOutput
        self.systemMessage = systemMessage
        self.hookSpecificOutput = hookSpecificOutput
    }
}
