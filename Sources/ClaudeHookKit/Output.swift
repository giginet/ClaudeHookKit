import Foundation

/// The base protocol for all hook output types.
///
/// Hooks communicate results through JSON output to stdout.
/// All output types share these common control properties.
public protocol StdoutOutput: Encodable, Sendable {
    /// Whether Claude should continue execution after this hook.
    ///
    /// When set to `false`, Claude stops processing entirely.
    /// This takes precedence over any `decision: block` output.
    var `continue`: Bool? { get }
    /// The reason for stopping, shown to the user (not to Claude).
    ///
    /// Only used when `continue` is `false`.
    var stopReason: String? { get }
    /// Whether to hide hook stdout from the user's transcript view.
    ///
    /// When `true`, the hook's output is hidden from the transcript
    /// displayed when pressing CTRL-R.
    var suppressOutput: Bool? { get }
    /// An optional warning or context message shown to the user.
    var systemMessage: String? { get }
}

/// A protocol for types that can be used as updated tool input.
///
/// Implement this protocol to define modified tool input parameters
/// for use with `PreToolUse` hooks' `updatedInput` feature.
public protocol UpdatedInputProtocol: Encodable, Sendable {}

/// The output returned from a `PreToolUse` hook.
///
/// Use this output to control whether a tool execution should proceed,
/// and optionally modify the tool input before execution.
public struct PreToolUseOutput<Input: UpdatedInputProtocol>: StdoutOutput {
    /// The permission decision for a tool execution.
    public enum PermissionDecision: String, Encodable, Sendable {
        /// Allow the tool to execute, bypassing the normal permission system.
        ///
        /// The `permissionDecisionReason` is shown to the user but not to Claude.
        case allow
        /// Deny the tool execution.
        ///
        /// The `permissionDecisionReason` is shown to Claude, allowing it to
        /// understand why the action was blocked and adjust its approach.
        case deny
        /// Ask the user for permission before executing.
        ///
        /// The `permissionDecisionReason` is shown to the user but not to Claude.
        case ask
    }

    /// The hook-specific output for `PreToolUse` hooks.
    public struct HookSpecificOutput: Encodable, Sendable {
        /// The name of the hook event.
        public var hookEventName: Event = .preToolUse
        /// The permission decision for this tool call.
        public var permissionDecision: PermissionDecision
        /// The reason for the permission decision.
        ///
        /// For `allow` and `ask`, this is shown to the user but not to Claude.
        /// For `deny`, this is shown to Claude to guide its next action.
        public var permissionDecisionReason: String
        /// Modified tool input parameters to use instead of the original.
        ///
        /// This allows transparent modification of tool inputs before execution.
        /// Most useful with `permissionDecision: .allow` to modify and approve
        /// tool calls in a single step. The modifications are invisible to Claude.
        public var updatedInput: Input?

        /// Creates a new hook-specific output.
        ///
        /// - Parameters:
        ///   - permissionDecision: The permission decision for this tool.
        ///   - permissionDecisionReason: The reason for the decision.
        ///   - updatedInput: Modified input parameters to use, if any.
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

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The hook-specific output containing the permission decision.
    public var hookSpecificOutput: HookSpecificOutput?

    /// Creates a new pre-tool use output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - hookSpecificOutput: The permission decision and optional input modifications.
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

/// The output returned from a `PostToolUse` hook.
///
/// Use this output to add context based on tool results, log tool usage,
/// or block further processing. Progress is shown in verbose mode (CTRL-O).
public struct PostToolUseOutput: StdoutOutput {
    /// The decision for post-tool use processing.
    public enum Decision: String, Encodable, Sendable {
        /// Block further processing of this tool's result.
        ///
        /// The `reason` field is fed back to Claude, explaining why
        /// the result was blocked and guiding its next action.
        case block
    }

    /// The hook-specific output for `PostToolUse` hooks.
    public struct HookSpecificOutput: Encodable, Sendable {
        /// The name of the hook event.
        public var hookEventName: Event = .postToolUse
        /// Additional context to add based on the tool result.
        ///
        /// This context is provided to Claude to help inform its next action.
        public var additionalContext: String

        /// Creates a new hook-specific output.
        ///
        /// - Parameter additionalContext: Context to add based on tool result.
        init(additionalContext: String) {
            self.additionalContext = additionalContext
        }
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The decision for this tool result.
    ///
    /// Use `block` to prevent further processing. The `reason` is
    /// fed back to Claude to guide its next action.
    public var decision: Decision?
    /// The reason for the decision, shown to Claude when blocking.
    public var reason: String?
    /// The hook-specific output with additional context.
    public var hookSpecificOutput: HookSpecificOutput?

    /// Creates a new post-tool use output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - decision: The decision for this tool result.
    ///   - reason: The reason for blocking (shown to Claude).
    ///   - hookSpecificOutput: Additional context based on tool result.
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

/// The output returned from a `Notification` hook.
///
/// This hook is purely informational and cannot block Claude Code behavior.
/// Output is logged to debug only (use `--debug` flag to see).
public struct NotificationOutput: StdoutOutput {
    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?

    /// Creates a new notification output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
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

/// The output returned from a `UserPromptSubmit` hook.
///
/// Use this output to validate, block, or add context to user prompts.
/// Stdout from this hook is added as context for Claude before processing.
public struct UserPromptSubmitOutput: StdoutOutput {
    /// The decision for user prompt submission.
    public enum Decision: String, Encodable, Sendable {
        /// Block the prompt from being processed.
        ///
        /// The `reason` is shown to Claude to explain why the prompt was blocked.
        case block
    }

    /// The hook-specific output for `UserPromptSubmit` hooks.
    public struct HookSpecificOutput: Encodable, Sendable {
        /// The name of the hook event.
        public var hookEventName: Event = .userPromptSubmit
        /// Additional context to inject into the conversation.
        ///
        /// This context is added before Claude processes the user's prompt.
        public var additionalContext: String?

        /// Creates a new hook-specific output.
        ///
        /// - Parameter additionalContext: Context to inject before processing.
        public init(additionalContext: String? = nil) {
            self.additionalContext = additionalContext
        }
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The decision for this prompt.
    ///
    /// Use `block` to prevent the prompt from being processed.
    public var decision: Decision?
    /// The reason for blocking, shown to Claude.
    public var reason: String?
    /// The hook-specific output with additional context.
    public var hookSpecificOutput: HookSpecificOutput?

    /// Creates a new user prompt submit output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - decision: The decision for this prompt.
    ///   - reason: The reason for blocking (shown to Claude).
    ///   - hookSpecificOutput: Additional context to inject.
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

/// The output returned from a `Stop` hook.
///
/// Use this output to control whether Claude should continue or stop.
/// Setting `decision: .block` prevents Claude from stopping and the `reason`
/// is fed back to Claude to guide its next action.
public struct StopOutput: StdoutOutput {
    /// The decision for the stop action.
    public enum Decision: String, Encodable, Sendable {
        /// Prevent Claude from stopping and force it to continue.
        ///
        /// You must provide a `reason` to guide Claude on how to proceed.
        case block
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The decision for this stop action.
    ///
    /// Use `block` to prevent Claude from stopping. If undefined,
    /// Claude is allowed to stop and `reason` is ignored.
    public var decision: Decision?
    /// The reason for blocking, fed back to Claude.
    ///
    /// This is crucial when blocking - it tells Claude why it
    /// cannot stop and guides its next action.
    public var reason: String?

    /// Creates a new stop output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - decision: The decision for this stop action.
    ///   - reason: The reason for blocking (shown to Claude).
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

/// The output returned from a `SubagentStop` hook.
///
/// Use this output to control whether a subagent should continue or stop.
/// Setting `decision: .block` prevents the subagent from stopping.
public struct SubagentStopOutput: StdoutOutput {
    /// The decision for the subagent stop action.
    public enum Decision: String, Encodable, Sendable {
        /// Prevent the subagent from stopping and force it to continue.
        ///
        /// You must provide a `reason` to guide the subagent on how to proceed.
        case block
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The decision for this stop action.
    ///
    /// Use `block` to prevent the subagent from stopping.
    public var decision: Decision?
    /// The reason for blocking, fed back to the subagent.
    public var reason: String?

    /// Creates a new subagent stop output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - decision: The decision for this stop action.
    ///   - reason: The reason for blocking (shown to subagent).
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

/// The output returned from a `SessionStart` hook.
///
/// Use this output to initialize session resources or add context.
/// Stdout from this hook is added as context for Claude.
public struct SessionStartOutput: StdoutOutput {
    /// The hook-specific output for `SessionStart` hooks.
    public struct HookSpecificOutput: Encodable, Sendable {
        /// The name of the hook event.
        public var hookEventName: Event = .sessionStart
        /// Additional context to inject at session start.
        ///
        /// This context is provided to Claude at the beginning of the session.
        public var additionalContext: String?

        /// Creates a new hook-specific output.
        ///
        /// - Parameter additionalContext: Context to inject at session start.
        public init(additionalContext: String? = nil) {
            self.additionalContext = additionalContext
        }
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The hook-specific output with additional context.
    public var hookSpecificOutput: HookSpecificOutput?

    /// Creates a new session start output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - hookSpecificOutput: Additional context to inject.
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

/// The output returned from a `SessionEnd` hook.
///
/// Use this output for cleanup, logging, or saving session data.
/// Output is logged to debug only (use `--debug` flag to see).
public struct SessionEndOutput: StdoutOutput {
    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?

    /// Creates a new session end output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
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

/// The output returned from a `PermissionRequest` hook.
///
/// Use this output to automatically allow or deny permission requests
/// and optionally modify the input parameters.
public struct PermissionRequestOutput<Input: UpdatedInputProtocol>: StdoutOutput {
    /// The decision for a permission request.
    public enum PermissionDecision: Sendable {
        /// Allow the action to proceed.
        ///
        /// - Parameter updatedInput: Modified input parameters to use instead of the original.
        case allow(updatedInput: Input? = nil)

        /// Deny the action.
        ///
        /// - Parameters:
        ///   - message: The reason for denying, shown to Claude.
        ///   - interrupt: Whether to stop Claude execution.
        case deny(message: String? = nil, interrupt: Bool? = nil)
    }

    /// The hook-specific output for `PermissionRequest` hooks.
    public struct HookSpecificOutput: Encodable, Sendable {
        /// The name of the hook event.
        public var hookEventName: Event = .permissionRequest
        /// The decision for this permission request.
        public var decision: PermissionDecision

        /// Creates a new hook-specific output.
        ///
        /// - Parameter decision: The permission decision.
        public init(decision: PermissionDecision) {
            self.decision = decision
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(hookEventName, forKey: .hookEventName)

            var decisionContainer = container.nestedContainer(
                keyedBy: DecisionCodingKeys.self, forKey: .decision)
            switch decision {
            case .allow(let updatedInput):
                try decisionContainer.encode("allow", forKey: .behavior)
                try decisionContainer.encodeIfPresent(updatedInput, forKey: .updatedInput)
            case .deny(let message, let interrupt):
                try decisionContainer.encode("deny", forKey: .behavior)
                try decisionContainer.encodeIfPresent(message, forKey: .message)
                try decisionContainer.encodeIfPresent(interrupt, forKey: .interrupt)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case hookEventName = "hook_event_name"
            case decision
        }

        private enum DecisionCodingKeys: String, CodingKey {
            case behavior
            case updatedInput = "updated_input"
            case message
            case interrupt
        }
    }

    /// Whether Claude should continue execution after this hook.
    public var `continue`: Bool?
    /// The reason for stopping, shown to the user.
    public var stopReason: String?
    /// Whether to hide hook output from the transcript view.
    public var suppressOutput: Bool?
    /// An optional warning or context message shown to the user.
    public var systemMessage: String?
    /// The hook-specific output containing the permission decision.
    public var hookSpecificOutput: HookSpecificOutput?

    /// Creates a new permission request output.
    ///
    /// - Parameters:
    ///   - continue: Whether Claude should continue execution.
    ///   - stopReason: The reason for stopping (shown to user).
    ///   - suppressOutput: Whether to hide output from transcript.
    ///   - systemMessage: An optional message shown to the user.
    ///   - hookSpecificOutput: The permission decision.
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

    private enum CodingKeys: String, CodingKey {
        case `continue`
        case stopReason = "stop_reason"
        case suppressOutput = "suppress_output"
        case systemMessage = "system_message"
        case hookSpecificOutput = "hook_specific_output"
    }
}
