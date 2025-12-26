import Foundation

public protocol StdoutOutput: Encodable, Sendable {
  var `continue`: Bool? { get }
  var stopReason: String? { get }
  var suppressOutput: Bool? { get }
  var systemMessage: String? { get }
}

public protocol UpdatedInput: Encodable, Sendable {}

public struct PreToolUseOutput<Input: UpdatedInput>: StdoutOutput {
  public enum PermissionDecision: String, Encodable, Sendable {
    case allow
    case deny
    case ask
  }

  public struct HookSpecificOutput: Encodable, Sendable {
    public var hookEventName: Event = .preToolUse
    public var permissionDecision: PermissionDecision
    public var permissionDecisionReason: String
    public var updatedInput: Input?

    public init(
      permissionDecision: PermissionDecision,
      permissionDecisionReason: String,
      updatedInput: Input?
    ) {
      self.permissionDecision = permissionDecision
      self.permissionDecisionReason = permissionDecisionReason
      self.updatedInput = updatedInput
    }
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var hookSpecificOutput: HookSpecificOutput?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    hookSpecificOutput: HookSpecificOutput? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.hookSpecificOutput = hookSpecificOutput
  }
}

public struct PostToolUseOutput: StdoutOutput {
  public enum Decision: String, Encodable, Sendable {
    case block
  }

  public struct HookSpecificOutput: Encodable, Sendable {
    public var hookEventName: Event = .postToolUse
    public var additionalContext: String

    init(additionalContext: String) {
      self.additionalContext = additionalContext
    }
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var decision: Decision?
  public var reason: String?
  public var hookSpecificOutput: HookSpecificOutput?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    decision: Decision? = nil,
    reason: String? = nil,
    hookSpecificOutput: HookSpecificOutput? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.decision = decision
    self.reason = reason
    self.hookSpecificOutput = hookSpecificOutput
  }
}

public struct NotificationOutput: StdoutOutput {
  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
  }
}

public struct UserPromptSubmitOutput: StdoutOutput {
  public enum Decision: String, Encodable, Sendable {
    case block
  }

  public struct HookSpecificOutput: Encodable, Sendable {
    public var hookEventName: Event = .userPromptSubmit
    public var additionalContext: String?

    public init(additionalContext: String? = nil) {
      self.additionalContext = additionalContext
    }
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var decision: Decision?
  public var reason: String?
  public var hookSpecificOutput: HookSpecificOutput?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    decision: Decision? = nil,
    reason: String? = nil,
    hookSpecificOutput: HookSpecificOutput? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.decision = decision
    self.reason = reason
    self.hookSpecificOutput = hookSpecificOutput
  }
}

public struct StopOutput: StdoutOutput {
  public enum Decision: String, Encodable, Sendable {
    case block
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var decision: Decision?
  public var reason: String?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    decision: Decision? = nil,
    reason: String? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.decision = decision
    self.reason = reason
  }
}

public struct SubagentStopOutput: StdoutOutput {
  public enum Decision: String, Encodable, Sendable {
    case block
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var decision: Decision?
  public var reason: String?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    decision: Decision? = nil,
    reason: String? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.decision = decision
    self.reason = reason
  }
}

public struct SessionStartOutput: StdoutOutput {
  public struct HookSpecificOutput: Encodable, Sendable {
    public var hookEventName: Event = .sessionStart
    public var additionalContext: String?

    public init(additionalContext: String? = nil) {
      self.additionalContext = additionalContext
    }
  }

  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?
  public var hookSpecificOutput: HookSpecificOutput?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil,
    hookSpecificOutput: HookSpecificOutput? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
    self.hookSpecificOutput = hookSpecificOutput
  }
}

public struct SessionEndOutput: StdoutOutput {
  public var `continue`: Bool?
  public var stopReason: String?
  public var suppressOutput: Bool?
  public var systemMessage: String?

  public init(
    continue: Bool? = nil,
    stopReason: String? = nil,
    suppressOutput: Bool? = nil,
    systemMessage: String? = nil
  ) {
    self.continue = `continue`
    self.stopReason = stopReason
    self.suppressOutput = suppressOutput
    self.systemMessage = systemMessage
  }
}
