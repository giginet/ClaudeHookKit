import Foundation

public enum HookError<Output: StdoutOutput>: Error {
    case blockingError(Output?)
    case nonBlockingError(errorMessage: String?, Output?)
}

public protocol Hook {
    associatedtype Input: StdinInput
    associatedtype Output: StdoutOutput
    
    func invoke() throws(HookError<Output>)
}

public protocol PreToolUseHook: Hook
where Input == PreToolUseInput<HookToolInput>,
      Output == PreToolUseOutput<HookUpdatedInput> {
    associatedtype HookToolInput: ToolInput
    associatedtype HookUpdatedInput: UpdatedInput
}

public protocol PostToolUseHook: Hook
where Input == PostToolUseInput<HookToolInput, HookToolResponse>,
      Output == PostToolUseOutput {
    associatedtype HookToolInput: ToolInput
    associatedtype HookToolResponse: ToolResponse
}

public protocol NotificationHook: Hook
where Input == NotificationInput,
      Output == NotificationOutput {
}

public protocol UserPromptSubmitHook: Hook
where Input == UserPromptSubmitInput,
      Output == UserPromptSubmitOutput {
}

public protocol StopHook: Hook
where Input == StopInput,
      Output == StopOutput {
}

public protocol SubagentStopHook: Hook
where Input == SubagentStopInput,
      Output == SubagentStopOutput {
}

public protocol SessionStartHook: Hook
where Input == SessionStartInput,
      Output == SessionStartOutput {
}

public protocol SessionEndHook: Hook
where Input == SessionEndInput,
      Output == SessionEndOutput {
}
