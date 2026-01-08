import Foundation
import Testing

@testable import ClaudeHookKit

@Suite
struct UserPromptSubmitInputTests {
    @Test
    func parseUserPromptSubmitInput() throws {
        let json = """
            {
                "session_id": "2c0c9028-4e2a-457a-93fd-9f6309d64701",
                "transcript_path": "/path/to/.claude/projects/workspace/2c0c9028-4e2a-457a-93fd-9f6309d64701.jsonl",
                "cwd": "/path/to/workspace",
                "permission_mode": "default",
                "hook_event_name": "UserPromptSubmit",
                "prompt": "hi"
            }
            """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        let input = try decoder.decode(UserPromptSubmitInput.self, from: data)

        #expect(input.sessionID == UUID(uuidString: "2c0c9028-4e2a-457a-93fd-9f6309d64701"))
        #expect(
            input.transcriptPath.path()
                == "/path/to/.claude/projects/workspace/2c0c9028-4e2a-457a-93fd-9f6309d64701.jsonl"
        )
        #expect(input.cwd.path() == "/path/to/workspace")
        #expect(input.permissionMode == .default)
        #expect(input.hookEventName == .userPromptSubmit)
        #expect(input.prompt == "hi")
    }
}
