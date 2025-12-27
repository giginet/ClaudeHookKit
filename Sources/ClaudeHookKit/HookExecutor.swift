import Foundation
import Logging

private let blockingErrorExitCode: Int32 = 2

/// The logging mode for hook execution.
public enum LogMode {
    /// Logging is disabled.
    case disabled
    /// Logging is enabled, writing to the specified file URL.
    case enabled(URL)
}

struct HookExecutor<H: Hook> {
    private let logger: Logger
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    private let jsonEncoder: JSONEncoder = JSONEncoder()

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

    init(logMode: LogMode) {
        switch logMode {
        case .disabled:
            LoggingSystem.bootstrap { _ in NoOpLogHandler() }
        case .enabled(let logFileURL):
            let logFilePath = logFileURL.path()
            LoggingSystem.bootstrap { _ -> LogHandler in
                do {
                    return try FileLogHandler(filePath: logFilePath)
                } catch {
                    fatalError("Failed to initialize FileLogHandler: \(error)")
                }
            }
        }
        var logger = Logger(label: "me.giginet.ClaudeHookKit")
        switch logMode {
        case .disabled:
            logger.logLevel = .critical
        case .enabled:
            logger.logLevel = .debug
        }
        self.logger = logger
    }

    func execute() throws {
        let inputHandler = FileHandle.standardInput
        let isTTY = isatty(STDIN_FILENO) != 0
        guard !isTTY else {
            throw Error.invalidCall
        }
        let payloadData = inputHandler.readDataToEndOfFile()

        try inputHandler.close()

        if let payloadString = String(data: payloadData, encoding: .utf8) {
            logger.debug("Received payload: \(payloadString)")
        }

        let input: H.Input
        do {
            input = try jsonDecoder.decode(H.Input.self, from: payloadData)
        } catch {
            let inputString = String(data: payloadData, encoding: .utf8) ?? "<invalid data>"
            throw Error.invalidInput(error, inputString)
        }

        let context = Context(logger: logger)
        let outputResult = H.invoke(input: input, context: context)
        try handleHookResult(outputResult, logger: logger)
    }

    private func handleHookResult(_ hookResult: HookResult<H.Output>, logger: Logger) throws {
        switch hookResult {
        case .exitCode(.success):
            exit(EXIT_SUCCESS)
        case .exitCode(.blockingError):
            exit(blockingErrorExitCode)
        case .exitCode(.nonBlockingError(let exitCode)):
            if exitCode == blockingErrorExitCode {
                fatalError(
                    "nonBlockingError can't return 2 as exit code. Use blockingError instead.")
            }
            exit(exitCode)
        case .jsonOutput(let payload):
            let stdoutHandler = FileHandle.standardOutput
            defer { try? stdoutHandler.close() }
            let outputData = try jsonEncoder.encode(payload)

            if let outputDataString = String(data: outputData, encoding: .utf8) {
                logger.debug("Sending output payload: \(outputDataString)")
            }

            stdoutHandler.write(outputData)
        }
    }
}

/// The execution context provided to hooks.
///
/// The context provides access to logging and environment information
/// during hook execution.
public struct Context {
    /// The logger for outputting debug information.
    ///
    /// Use this logger instead of `print()` to avoid interfering
    /// with the hook's JSON output.
    public let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    /// The project directory path, if available.
    ///
    /// This is read from the `CLAUDE_PROJECT_DIR` environment variable
    /// set by Claude Code.
    public var projectDirectoryPath: URL? {
        guard let projectDirString = ProcessInfo.processInfo.environment["CLAUDE_PROJECT_DIR"]
        else {
            return nil
        }
        return URL(filePath: projectDirString)
    }
}

extension Hook {
    /// The entry point for hook execution.
    ///
    /// This method is automatically called when using the `@main` attribute
    /// on your hook struct. It handles:
    /// - Reading JSON input from stdin
    /// - Decoding input to the appropriate type
    /// - Calling your `invoke` method
    /// - Outputting results (exit code or JSON)
    /// - Error handling
    public static func main() throws {
        let executor = HookExecutor<Self>(logMode: .disabled)
        do {
            try executor.execute()
        } catch let error {
            print(error.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
}
