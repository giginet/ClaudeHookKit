import Foundation
import Logging

private let blockingErrorExitCode: Int32 = 2

public enum LogMode {
    case disabled
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
                if let handler = FileLogHandler(filePath: logFilePath) {
                    return handler
                }
                return NoOpLogHandler()
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

    func execute(hook: H) throws {
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
        let outputResult = hook.invoke(input: input, context: context)
        try handleHookResult(outputResult, logger: logger)
    }

    private func handleHookResult(_ hookResult: HookResult<H.Output>, logger: Logger) throws {
        switch hookResult {
        case .simple(.success):
            exit(EXIT_SUCCESS)
        case .simple(.blockingError):
            exit(blockingErrorExitCode)
        case .simple(.nonBlockingError(let exitCode)):
            if exitCode == blockingErrorExitCode {
                fatalError(
                    "nonBlockingError can't return 2 as exit code. Use blockingError instead.")
            }
            exit(exitCode)
        case .advanced(let payload):
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

public struct Context {
    public let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    public var projectDirectoryPath: URL? {
        guard let projectDirString = ProcessInfo.processInfo.environment["CLAUDE_PROJECT_DIR"]
        else {
            return nil
        }
        return URL(filePath: projectDirString)
    }
}

extension Hook {
    public func run(logMode: LogMode = .disabled) throws {
        let executor = HookExecutor<Self>(logMode: logMode)
        try executor.execute(hook: self)
    }
}
