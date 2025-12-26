import Foundation

private let blockingErrorExitCode: Int32 = 2

struct HookExecutor<H: Hook> {
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    enum Error: LocalizedError {
        case invalidInput(Swift.Error)
        case invalidCall
        
        var errorDescription: String? {
            switch self {
            case .invalidInput(let inputError):
                return "Failed to decode input: \(inputError)"
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
            throw Error.invalidInput(error)
        }
        
        let stdoutHandler = FileHandle.standardOutput
        defer { try? stdoutHandler.close() }
        
        let outputResult = hook.invoke(input: input)
        if let payload = outputResult.payload {
            let outputData = try jsonEncoder.encode(outputResult.payload)
            stdoutHandler.write(outputData)
        }
        
        switch outputResult.status {
        case .success:
            exit(EXIT_SUCCESS)
        case .blockingError:
            exit(blockingErrorExitCode)
        case .nonBlockingError(let exitCode):
            if exitCode == blockingErrorExitCode {
                fatalError("nonBlockingError can't return 2 as exit code. Use blockingError instead.")
            }
            exit(exitCode)
        }
    }
}

extension Hook {
    public func run() throws {
        let executor = HookExecutor<Self>()
        try executor.execute(hook: self)
    }
}
