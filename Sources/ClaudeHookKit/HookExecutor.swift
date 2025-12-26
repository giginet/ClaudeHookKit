import Foundation

private let blockingErrorExitCode: Int32 = 2

struct HookExecutor<H: Hook> {
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    enum Error: LocalizedError {
        case invalidInput(Swift.Error, String)
        case invalidCall
        
        var errorDescription: String? {
            switch self {
            case .invalidInput(let inputError, let rawValue):
                return "Failed to decode input: \(rawValue), \(inputError)"
            case .invalidCall:
                return "Call this script from Claude Code Hooks"
            }
        }
    }
    
    func execute(hook: H) throws {
        let inputHandler = FileHandle.standardInput
        let isTTY = isatty(STDIN_FILENO) != 0
        guard !isTTY else {
            throw Error.invalidCall
        }
        let payloadData = inputHandler.readDataToEndOfFile()
        
        try inputHandler.close()
        
        let input: H.Input
        do {
            input = try jsonDecoder.decode(H.Input.self, from: payloadData)
        } catch {
            let inputString = String(data: payloadData, encoding: .utf8) ?? "<invalid data>"
            throw Error.invalidInput(error, inputString)
        }
        
        let outputResult = hook.invoke(input: input)
        try handleHookResult(outputResult)
    }
    
    private func handleHookResult(_ hookResult: HookResult<H.Output>) throws {
        switch hookResult {
        case .simple(.success):
            exit(EXIT_SUCCESS)
        case .simple(.blockingError):
            exit(blockingErrorExitCode)
        case .simple(.nonBlockingError(let exitCode)):
            if exitCode == blockingErrorExitCode {
                fatalError("nonBlockingError can't return 2 as exit code. Use blockingError instead.")
            }
            exit(exitCode)
        case .advanced(let payload):
            let stdoutHandler = FileHandle.standardOutput
            defer { try? stdoutHandler.close() }
            let outputData = try jsonEncoder.encode(payload)
            stdoutHandler.write(outputData)
        }
    }
}

extension Hook {
    public func run() throws {
        let executor = HookExecutor<Self>()
        try executor.execute(hook: self)
    }
}
