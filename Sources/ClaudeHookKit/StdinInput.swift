import Foundation

public enum PermissionMode: String, Decodable {
    case `default`
    case plan
    case acceptEdits
    case bypassPermission
}


public protocol StdinInput: Decodable {
    var sessionID: String { get }
    var transcriptPath: URL { get }
    var currentWorkingDirectory: URL { get }
    var permissionMode: PermissionMode { get }
}

public struct PreToolUseInput: StdinInput {
    public struct ToolInput: Decodable {
        var filePath: URL
        var content: String
    }
    public var sessionID: String
    public var transcriptPath: URL
    public var currentWorkingDirectory: URL
    public var permissionMode: PermissionMode
    public var hookEventName: String
    public var toolName: String
}
