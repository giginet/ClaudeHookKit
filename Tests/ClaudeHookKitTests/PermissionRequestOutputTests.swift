import Foundation
import Testing

@testable import ClaudeHookKit

@Suite
struct PermissionRequestOutputTests {
    // MARK: - Helper

    private func encodeToJSON<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8)!
    }

    // MARK: - PermissionRequestOutput Tests

    @Test
    func encodePermissionRequestOutputWithAllowDecision() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            hookSpecificOutput: .init(
                decision: .allow()
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "allow"
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithAllowAndUpdatedInput() throws {
        struct TestUpdatedInput: UpdatedInputProtocol {
            let command: String
        }

        let output = PermissionRequestOutput(
            hookSpecificOutput: .init(
                decision: .allow(
                    updatedInput: TestUpdatedInput(command: "echo hello")
                )
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "allow",
                  "updated_input" : {
                    "command" : "echo hello"
                  }
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithDenyDecision() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            hookSpecificOutput: .init(
                decision: .deny()
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "deny"
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithDenyMessageAndInterrupt() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            hookSpecificOutput: .init(
                decision: .deny(
                    message: "Blocked dangerous command",
                    interrupt: true
                )
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "deny",
                  "interrupt" : true,
                  "message" : "Blocked dangerous command"
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithDenyMessageOnly() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            hookSpecificOutput: .init(
                decision: .deny(message: "Access denied")
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "deny",
                  "message" : "Access denied"
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithDenyInterruptOnly() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            hookSpecificOutput: .init(
                decision: .deny(interrupt: true)
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "deny",
                  "interrupt" : true
                },
                "hook_event_name" : "PermissionRequest"
              }
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithCommonFields() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            continue: false,
            stopReason: "Hook blocked execution",
            suppressOutput: true,
            systemMessage: "Warning: dangerous command detected",
            hookSpecificOutput: .init(
                decision: .deny(message: "Blocked")
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "continue" : false,
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "deny",
                  "message" : "Blocked"
                },
                "hook_event_name" : "PermissionRequest"
              },
              "stop_reason" : "Hook blocked execution",
              "suppress_output" : true,
              "system_message" : "Warning: dangerous command detected"
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputWithoutHookSpecificOutput() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            systemMessage: "Just a notification"
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "system_message" : "Just a notification"
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputComplexUpdatedInput() throws {
        struct ComplexUpdatedInput: UpdatedInputProtocol {
            let command: String
            let arguments: [String]
            let environment: [String: String]
        }

        let output = PermissionRequestOutput(
            suppressOutput: true,
            hookSpecificOutput: .init(
                decision: .allow(
                    updatedInput: ComplexUpdatedInput(
                        command: "npm",
                        arguments: ["run", "test"],
                        environment: ["NODE_ENV": "test"]
                    )
                )
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "allow",
                  "updated_input" : {
                    "arguments" : [
                      "run",
                      "test"
                    ],
                    "command" : "npm",
                    "environment" : {
                      "NODE_ENV" : "test"
                    }
                  }
                },
                "hook_event_name" : "PermissionRequest"
              },
              "suppress_output" : true
            }
            """

        #expect(json == expected)
    }

    @Test
    func encodePermissionRequestOutputAllCommonFieldsSet() throws {
        struct EmptyInput: UpdatedInputProtocol {}

        let output = PermissionRequestOutput<EmptyInput>(
            continue: true,
            stopReason: nil,
            suppressOutput: false,
            systemMessage: "Info message",
            hookSpecificOutput: .init(
                decision: .allow()
            )
        )

        let json = try encodeToJSON(output)
        let expected = """
            {
              "continue" : true,
              "hook_specific_output" : {
                "decision" : {
                  "behavior" : "allow"
                },
                "hook_event_name" : "PermissionRequest"
              },
              "suppress_output" : false,
              "system_message" : "Info message"
            }
            """

        #expect(json == expected)
    }
}
