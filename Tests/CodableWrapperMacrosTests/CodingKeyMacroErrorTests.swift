//
// CodingKeyMacroErrorTests.swift
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodableWrapperMacros)
// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
@testable import CodableWrapperMacros

final class CodingKeyMacroErrorTests: XCTestCase {
    func testMultipleMacrosWithCodingKey() throws {
#if canImport(SwiftSyntax600)
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @CustomCodingKey("testKey") @SnakeCase
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
            
                let originalKey: String
            
                private enum CodingKeys: String, CodingKey {
                    case originalKey = "testKey"
                }
            }
            """,
            diagnostics: [.init(warning: .defaultingToCodingKey, line: 2, column: 5)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @SnakeCase @CustomCodingKey("testKey")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
            
                let originalKey: String
            
                private enum CodingKeys: String, CodingKey {
                    case originalKey = "testKey"
                }
            }
            """,
            diagnostics: [.init(warning: .defaultingToCodingKey, line: 2, column: 5)],
            macros: testMacros)
#else
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @CustomCodingKey("testKey") @SnakeCase
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String

                private enum CodingKeys: String, CodingKey {
                    case originalKey = "testKey"
                }
            }
            """,
            diagnostics: [.init(warning: .defaultingToCodingKey, line: 2, column: 5)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @SnakeCase @CustomCodingKey("testKey")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String

                private enum CodingKeys: String, CodingKey {
                    case originalKey = "testKey"
                }
            }
            """,
            diagnostics: [.init(warning: .defaultingToCodingKey, line: 2, column: 5)],
            macros: testMacros)
#endif
    }

    func testMultipleCodingKeyMacrosThrowsWarning() throws {
#if canImport(SwiftSyntax600)
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @SnakeCase @CamelCase @ScreamingSnakeCase
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
            
                let originalKey: String
            
                private enum CodingKeys: String, CodingKey {
                    case originalKey = "original_key"
                }
            }
            """,
            diagnostics: [.init(warning: .multipleCodingKeyAttributes, line: 2, column: 5)],
            macros: testMacros)
#else
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @SnakeCase @CamelCase @ScreamingSnakeCase
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String

                private enum CodingKeys: String, CodingKey {
                    case originalKey = "original_key"
                }
            }
            """,
            diagnostics: [.init(warning: .multipleCodingKeyAttributes, line: 2, column: 5)],
            macros: testMacros)
#endif
        assertMacroExpansion(
            """
            @CustomCodable @SnakeCase @CamelCase @ScreamingSnakeCase
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String

                private enum CodingKeys: String, CodingKey {
                    case originalKey = "original_key"
                }
            }
            """,
            diagnostics: [.init(warning: .multipleCodingKeyAttributes, line: 1, column: 1)],
            macros: testMacros)

            // making this work will need some refactoring
//        assertMacroExpansion(
//            """
//            @CustomCodable struct TestCodable: Codable {
//                @CodingKey("first") @CodingKey("second")
//                let originalKey: String
//            }
//            """,
//            expandedSource: """
//            struct TestCodable: Codable {
//                let originalKey: String
//
//                private enum CodingKeys: String, CodingKey {
//                    case originalKey = "first"
//                }
//            }
//            """,
//            diagnostics: [.init(warning: .multipleCodingKeyAttributes, line: 2, column: 5)],
//            macros: testMacros)
    }

    func testThrowsErrorWhenCodingKeysImplemented() throws {
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                let originalKey: String

                enum CodingKeys: String, CodingKey {
                    case originalKey
                }
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String

                enum CodingKeys: String, CodingKey {
                    case originalKey
                }
            }
            """,
            diagnostics: [.init(error: .codingKeysExist, line: 1, column: 1)],
            macros: testMacros)
    }

    func testThrowsDueToNonStringLiteral() throws {
        assertMacroExpansion(
            """
            let customKey = "customKey"
            @CustomCodable struct TestCodable: Codable {
                @CustomCodingKey(customKey)
                let originalKey: String
            }
            """,
            expandedSource: """
            let customKey = "customKey"
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .mustBeStringLiteral, line: 3, column: 5)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @CustomCodingKey(1)
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .mustBeStringLiteral, line: 2, column: 5)],
            macros: testMacros)
    }

    func testThrowsDueToEmptyStringCodingKey() throws {
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                @CustomCodingKey("")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .codingKeyValueCannotBeEmpty, line: 2, column: 5)],
            macros: testMacros)
    }

    func testThrowsDueToNoCodableMacro() throws {
        assertMacroExpansion(
            """
            @SnakeCase struct TestCodable: Codable {
                @CustomCodingKey("")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .requiresCodableMacro(macroName: "SnakeCase"), line: 1, column: 1)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @CodingKeySuffix struct TestCodable: Codable {
                @CustomCodingKey("")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .requiresCodableMacro(macroName: "CodingKeySuffix"), line: 1, column: 1)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @CodingKeyPrefix struct TestCodable: Codable {
                @CustomCodingKey("")
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .requiresCodableMacro(macroName: "CodingKeyPrefix"), line: 1, column: 1)],
            macros: testMacros)
    }

    func testThrowsWhenNotStruct() throws {
        assertMacroExpansion(
            """
            @CustomCodable class TestCodable: Codable {
                let originalKey: String
            }
            """,
            expandedSource: """
            class TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .canOnlyBeAttachedToStruct(name: "@CustomCodable"), line: 1, column: 1)],
            macros: testMacros)

        assertMacroExpansion(
            """
            @SnakeCase enum TestCodable: Codable {
                case test
            }
            """,
            expandedSource: """
            enum TestCodable: Codable {
                case test
            }
            """,
            diagnostics: [.init(error: .canOnlyBeAttachedToPropertiesAndStructs(name: "@SnakeCase"), line: 1, column: 1)],
            macros: testMacros)
    }

    func testThrowsWithEmptyCodingKey() throws {
        assertMacroExpansion(
            """
            @CustomCodable @SnakeCase struct TestCodable: Codable {
                @CustomCodingKey()
                let originalKey: String
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
            }
            """,
            diagnostics: [.init(error: .codingKeyValueRequired, line: 2, column: 5)],
            macros: testMacros)
    }

    func testThrowsWhenAttachedToFunction() throws {
        assertMacroExpansion(
            """
            @CustomCodable struct TestCodable: Codable {
                let originalKey: String
                @CustomCodingKey("test")
                func test() -> String { "" }
            }
            """,
            expandedSource: """
            struct TestCodable: Codable {
                let originalKey: String
                func test() -> String { "" }
            
                private enum CodingKeys: String, CodingKey {
                    case originalKey = "originalKey"
                }
            }
            """,
            diagnostics: [.init(error: .canOnlyBeAttachedToProperty(name: "@CustomCodingKey"), line: 3, column: 5)],
            macros: testMacros)
    }
}

#endif
