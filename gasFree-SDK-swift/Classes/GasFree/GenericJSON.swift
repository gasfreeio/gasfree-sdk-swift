import Foundation

/// A struct represents EIP712 type tuple
struct EIP712Type: Codable {
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
            return try! String(data: encoder.encode(self), encoding: .utf8)!
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
