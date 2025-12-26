import Foundation

private let blockingErrorExitCode: Int32 = 2

public struct HookExecutor<H: Hook> {
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
        case invalidInput(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidInput(let inputString):
                return "Failed to decode input: \(inputString)"
            }
        }
    }
    
    func execute(hook: H) throws {
        let inputHandler = FileHandle.standardInput
        let payloadData = inputHandler.availableData
        let input: H.Input
        do {
            input = try jsonDecoder.decode(H.Input.self, from: payloadData)
        } catch {
            let inputString = String(data: payloadData, encoding: .utf8) ?? "<invalid data>"
            throw Error.invalidInput(inputString)
        }
        
        do {
            try hook.invoke(input: input)
            exit(EXIT_SUCCESS)
        } catch {
            let stdoutHandler = FileHandle.standardOutput
            
            switch error {
            case .blockingError(let output):
                let outputData = try jsonEncoder.encode(output)
                stdoutHandler.write(outputData)
                
                exit(blockingErrorExitCode)
            case .nonBlockingError(let exitCode, let output):
                if exitCode == blockingErrorExitCode {
                    fatalError("nonBlockingError can't return 2 as exit code. Use blockingError instead.")
                }
                
                let outputData = try jsonEncoder.encode(output)
                stdoutHandler.write(outputData)
                
                exit(exitCode)
            }
        }
    }
}
