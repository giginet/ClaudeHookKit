import Foundation
import Logging

struct FileLogHandler: LogHandler {
    enum Error: LocalizedError {
        case failedToOpenFile(String)

        var errorDescription: String? {
            switch self {
            case .failedToOpenFile(let path):
                return "Failed to open log file: \(path)"
            }
        }
    }

    private let fileHandle: FileHandle
    var logLevel: Logger.Level = .debug
    var metadata: Logger.Metadata = [:]

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    init(filePath: String) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil)
        }
        guard let handle = FileHandle(forWritingAtPath: filePath) else {
            throw Error.failedToOpenFile(filePath)
        }
        self.fileHandle = handle
        try self.fileHandle.seekToEnd()
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(level)] \(message)\n"
        if let data = logMessage.data(using: .utf8) {
            try? fileHandle.write(contentsOf: data)
        }
    }
}

struct NoOpLogHandler: LogHandler {
    var logLevel: Logger.Level = .critical
    var metadata: Logger.Metadata = [:]

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { nil }
        set {}
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {}
}
