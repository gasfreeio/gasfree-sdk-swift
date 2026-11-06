// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

/// https://github.com/zoul/generic-json-swift
import Foundation

/// A struct represents EIP712 type tuple
struct EIP712Type: Codable, Equatable {
    let name: String
    let type: String
}

/// A struct represents EIP712 TypedData
struct EIP712TypedData: Codable {
    let types: [String: [EIP712Type]]
    let primaryType: String
    let domain: JSON
    let message: JSON

    var domainName: String {
        switch domain {
        case .object(let dictionary):
            switch dictionary["name"] {
            case .string(let value):
                return value
            case .array, .object, .number, .bool, .null, .none:
                return ""
            }
        case .array, .string, .number, .bool, .null:
            return ""
        }
    }
    var chainId: String {
        switch domain {
        case .object(let dictionary):
            switch dictionary["chainId"] {
            case .string(let value):
                return value
            case .number(let value):
                return "\(value)"
            case .array, .object, .bool, .null, .none:
                return ""
            }
        case .array, .string, .number, .bool, .null:
            return ""
        }
    }
}

extension EIP712TypedData.JSON: Codable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(array):
            try container.encode(array)
        case let .object(object):
            try container.encode(object)
        case let .string(string):
            try container.encode(string)
        case let .number(number):
            try container.encode(number)
        case let .bool(bool):
            try container.encode(bool)
        case .null:
            try container.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let object = try? container.decode([String: EIP712TypedData.JSON].self) {
            self = .object(object)
        } else if let array = try? container.decode([EIP712TypedData.JSON].self) {
            self = .array(array)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(EIP712TypedData.NumberValue.self) {
            self = .number(number)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
}

extension EIP712TypedData.JSON: CustomDebugStringConvertible {

    var debugDescription: String {
        switch self {
        case .string(let str):
            return str.debugDescription
        case .number(let num):
            return num.description
        case .bool(let bool):
            return bool.description
        case .null:
            return "null"
        default:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            do {
                let data = try encoder.encode(self)
                return String(data: data, encoding: .utf8) ?? ""
            } catch {
                return ""
            }
        }
    }
}

extension EIP712TypedData.JSON {
    /// Return the string value if this is a `.string`, otherwise `nil`
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    /// Return the float value if this is a `.number`, otherwise `nil`
    var numberValue: EIP712TypedData.NumberValue? {
        if case .number(let value) = self {
            return value
        }
        return nil
    }

    /// Return the bool value if this is a `.bool`, otherwise `nil`
    var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

    /// Return the object value if this is an `.object`, otherwise `nil`
    var objectValue: [String: EIP712TypedData.JSON]? {
        if case .object(let value) = self {
            return value
        }
        return nil
    }

    /// Return the array value if this is an `.array`, otherwise `nil`
    var arrayValue: [EIP712TypedData.JSON]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }

    /// Return `true` if this is `.null`
    var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }

    /// If this is an `.array`, return item at index
    ///
    /// If this is not an `.array` or the index is out of bounds, returns `nil`.
    subscript(index: Int) -> EIP712TypedData.JSON? {
        if case .array(let arr) = self, arr.indices.contains(index) {
            return arr[index]
        }
        return nil
    }

    /// If this is an `.object`, return item at key
    subscript(key: String) -> EIP712TypedData.JSON? {
        if case .object(let dict) = self {
            return dict[key]
        }
        return nil
    }
}

/// A JSON value representation. This is a bit more useful than the naïve `[String:Any]` type
/// for JSON values, since it makes sure only valid JSON values are present & supports `Equatable`
/// and `Codable`, so that you can compare values for equality and code and decode them into data
/// or strings.
extension EIP712TypedData {
    enum NumberValue: Equatable, Codable, CustomStringConvertible {
        case double(Double)
        case int(Int)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let value = try? container.decode(Int.self) {
                self = .int(value)
            } else if let value = try? container.decode(Double.self) {
                self = .double(value)
            } else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .int(value):
                try container.encode(value)
            case let .double(value):
                try container.encode(value)
            }
        }

        var description: String {
            switch self {
            case let .int(value):
                return value.description
            case let .double(value):
                return value.description
            }
        }
    }

    enum JSON: Equatable {
        case string(String)
        case number(EIP712TypedData.NumberValue)
        case object([String: JSON])
        case array([JSON])
        case bool(Bool)
        case null
    }
}

/// Checks information that JSONDecoder would otherwise discard. The fixed
/// GasFree schema has only unsigned integer numeric fields; strings are still
/// decoded and validated by the existing typed-data and ABI code.
struct GasFreeJSONBoundary {
    private let bytes: [UInt8]
    private var index = 0

    static func validate(_ data: Data) throws {
        var scanner = GasFreeJSONBoundary(bytes: Array(data), index: 0)
        // Preserve Foundation's support for a UTF-8 byte order mark.
        if scanner.bytes.starts(with: [0xef, 0xbb, 0xbf]) {
            scanner.index = 3
        }
        try scanner.scanValue(depth: 0)
        scanner.skipWhitespace()
        guard scanner.index == scanner.bytes.count else {
            throw scanner.error("Unexpected trailing JSON content")
        }
    }

    private mutating func scanValue(depth: Int) throws {
        skipWhitespace()
        guard index < bytes.count else { throw error("Missing JSON value") }
        switch bytes[index] {
        case 0x7b, 0x5b: // object or array
            // Bound recursion in this preflight scanner, before Foundation runs.
            guard depth < 64 else { throw error("JSON nesting exceeds 64 levels") }
            let isObject = bytes[index] == 0x7b
            let closing: UInt8 = isObject ? 0x7d : 0x5d
            index += 1
            skipWhitespace()
            if consume(closing) { return }
            var keys = Set<String>()
            while true {
                if isObject {
                    let range = try scanString()
                    // Compare decoded keys so Unicode-escaped aliases also collide.
                    let key = try JSONDecoder().decode(String.self, from: Data(bytes[range]))
                    guard keys.insert(key).inserted else {
                        throw error("Duplicate JSON object key")
                    }
                    skipWhitespace()
                    try expect(0x3a) // colon
                }
                try scanValue(depth: depth + 1)
                skipWhitespace()
                if consume(closing) { return }
                try expect(0x2c) // comma
                skipWhitespace()
            }
        case 0x22:
            _ = try scanString()
        case 0x30...0x39:
            let start = index
            while index < bytes.count, (0x30...0x39).contains(bytes[index]) {
                index += 1
                guard index - start <= 78 else { throw error("JSON integer exceeds 78 digits") }
            }
            guard index - start == 1 || bytes[start] != 0x30 else {
                throw error("Leading zeros in JSON number")
            }
            if index < bytes.count, [0x2e, 0x65, 0x45].contains(bytes[index]) {
                throw error("JSON numbers must be unsigned integer literals, without fractions or exponents")
            }
        case 0x74:
            try expectLiteral("true")
        case 0x66:
            try expectLiteral("false")
        case 0x6e:
            try expectLiteral("null")
        default:
            throw error("Invalid JSON value; numbers must be unsigned integer literals")
        }
    }

    private mutating func scanString() throws -> Range<Int> {
        let start = index
        try expect(0x22)
        while index < bytes.count {
            let byte = bytes[index]
            index += 1
            if byte == 0x22 { return start..<index }
            if byte == 0x5c {
                guard index < bytes.count else { throw error("Unterminated JSON escape") }
                index += 1 // Escaped quotes cannot close the string.
            }
        }
        throw error("Unterminated JSON string")
    }

    private mutating func skipWhitespace() {
        while index < bytes.count, [0x20, 0x09, 0x0a, 0x0d].contains(bytes[index]) {
            index += 1
        }
    }

    private mutating func consume(_ byte: UInt8) -> Bool {
        guard index < bytes.count, bytes[index] == byte else { return false }
        index += 1
        return true
    }

    private mutating func expect(_ byte: UInt8) throws {
        guard consume(byte) else { throw error("Invalid JSON syntax") }
    }

    private mutating func expectLiteral(_ literal: String) throws {
        for byte in literal.utf8 { try expect(byte) }
    }

    private func error(_ message: String) -> DecodingError {
        return .dataCorrupted(.init(codingPath: [], debugDescription: "\(message) at byte \(index)."))
    }
}
