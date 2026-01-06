import Foundation
import Testing

@testable import ClaudeHookKit

@Suite
struct PermissionRequestInputTests {
    @Test
    func parsePermissionRequestInput() throws {
        struct BashToolInput: ToolInput {
            let command: String
            let description: String
        }

        let json = """
            {
                "session_id": "6115c7f2-6ff5-4977-b126-bfbfbaf65e66",
                "transcript_path": "/home/user/.claude/projects/my-project/6115c7f2-6ff5-4977-b126-bfbfbaf65e66.jsonl",
                "cwd": "/home/user/projects/my-project",
                "permission_mode": "acceptEdits",
                "hook_event_name": "PermissionRequest",
                "tool_name": "Bash",
                "tool_input": {
                    "command": "echo 'Hello World'",
                    "description": "Print greeting message"
                }
            }
            """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        let input = try decoder.decode(
            PermissionRequestInput<BashToolInput>.self, from: data)

        #expect(input.sessionID == UUID(uuidString: "6115c7f2-6ff5-4977-b126-bfbfbaf65e66"))
        #expect(
            input.transcriptPath.path()
                == "/home/user/.claude/projects/my-project/6115c7f2-6ff5-4977-b126-bfbfbaf65e66.jsonl"
        )
        #expect(input.cwd.path() == "/home/user/projects/my-project")
        #expect(input.permissionMode == .acceptEdits)
        #expect(input.hookEventName == .PermissionRequest)
        #expect(input.toolName == "Bash")
        #expect(input.toolInput?.command == "echo 'Hello World'")
        #expect(input.toolInput?.description == "Print greeting message")
    }

    @Test
    func parsePermissionRequestInputWithComplexCommand() throws {
        struct BashToolInput: ToolInput {
            let command: String
            let description: String
        }

        let json = """
            {
                "session_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
                "transcript_path": "/home/user/.claude/projects/test-project/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jsonl",
                "cwd": "/home/user/workspace/test-project",
                "permission_mode": "acceptEdits",
                "hook_event_name": "PermissionRequest",
                "tool_name": "Bash",
                "tool_input": {
                    "command": "python3 << 'SCRIPT'\\nimport os\\nprint('Working')\\nSCRIPT\\n",
                    "description": "Execute Python script"
                }
            }
            """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        let input = try decoder.decode(
            PermissionRequestInput<BashToolInput>.self, from: data)

        #expect(input.sessionID == UUID(uuidString: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"))
        #expect(input.toolName == "Bash")
        #expect(input.toolInput?.command.contains("python3") == true)
        #expect(input.toolInput?.description == "Execute Python script")
    }
}
