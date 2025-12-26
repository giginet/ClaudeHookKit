import Foundation
import Logging

public enum HookResult<Output: StdoutOutput> {
    public enum ExitCodeStatus {
        case success
        case blockingError
        case nonBlockingError(exitCode: Int32)
    }
    case exitCode(ExitCodeStatus)
    case jsonOutput(Output)
}

public protocol Hook {
    associatedtype Input: StdinInput
    associatedtype Output: StdoutOutput

    func invoke(input: Input, context: Context) -> HookResult<Output>
}

public struct NeverToolInput: ToolInput {}
public struct NeverToolResponse: ToolResponse {}

public protocol PreToolUseHook: Hook
where
    Input == PreToolUseInput<HookToolInput>,
    Output == PreToolUseOutput<HookUpdatedInput>
{
    associatedtype HookToolInput: ToolInput
    associatedtype HookUpdatedInput: UpdatedInput
}

public protocol PostToolUseHook: Hook
where
    Input == PostToolUseInput<HookToolInput, HookToolResponse>,
    Output == PostToolUseOutput
{
    associatedtype HookToolInput: ToolInput
    associatedtype HookToolResponse: ToolResponse
}

public protocol NotificationHook: Hook
where
    Input == NotificationInput,
    Output == NotificationOutput
{
}

public protocol UserPromptSubmitHook: Hook
where
    Input == UserPromptSubmitInput,
    Output == UserPromptSubmitOutput
{
}

public protocol StopHook: Hook
where
    Input == StopInput,
    Output == StopOutput
{
}

public protocol SubagentStopHook: Hook
where
    Input == SubagentStopInput,
    Output == SubagentStopOutput
{
}

public protocol SessionStartHook: Hook
where
    Input == SessionStartInput,
    Output == SessionStartOutput
{
}

public protocol SessionEndHook: Hook
where
    Input == SessionEndInput,
    Output == SessionEndOutput
{
}

public struct Empty: ToolInput, ToolResponse, UpdatedInput {
}
