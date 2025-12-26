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
