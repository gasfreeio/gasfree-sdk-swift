// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
import Foundation
import BigInt
import TLCore
import CryptoSwift


let identifierPattern = "^[a-zA-Z_$][a-zA-Z_$0-9]*$"
let typePattern = "^[a-zA-Z_$][a-zA-Z_$0-9]*(\\[([1-9]\\d*)*\\])*$"

enum EIP712Error: Error{
    case TypeParamError (String)
    case OtherError (String)
}

extension EIP712TypedData {
    /// Sign-able hash for an `EIP712TypedData`
    func signHash() throws -> Data {
        guard types["EIP712Domain"] != nil,
              checkTypeParam(primaryType: "EIP712Domain"),
              checkTypeParam(primaryType: primaryType) else {
            throw EIP712Error.TypeParamError("invalid eip712 schema")
        }
        let domainData = try hashStruct(domain, type: "EIP712Domain")
        let messageData = try hashStruct(message, type: primaryType)
        let data = Data(bytes: [0x19, 0x01]) + domainData + messageData
        return Crypto.hash(data)
    }
    
    func signEip712Hash() throws -> (hashData: Data,domainData: Data,messageData: Data) {
        guard types["EIP712Domain"] != nil,
              checkTypeParam(primaryType: "EIP712Domain"),
              checkTypeParam(primaryType: primaryType) else {
            throw EIP712Error.TypeParamError("invalid eip712 schema")
        }
        let domainData = try hashStruct(domain, type: "EIP712Domain")
        let messageData = try hashStruct(message, type: primaryType)
        let data = Data(bytes: [0x19, 0x01]) + domainData + messageData
        return (Crypto.hash(data), domainData, messageData)
    }

    static func normalizedChainId(_ chainId: String) -> BigUInt? {
        let value = chainId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        if value.lowercased().hasPrefix("0x") {
            let hex = String(value.dropFirst(2))
            return hex.isEmpty ? nil : BigUInt(hex, radix: 16)
        }
        return BigUInt(value, radix: 10)
    }

    /// Recursively finds all the dependencies of a type
    func findDependencies(primaryType: String, dependencies: Set<String> = Set<String>()) -> Set<String> {
        var found = dependencies
        // fix search array types
        var primaryType = primaryType
        if let indexOfOpenBracket = primaryType.index(of: "["), primaryType.hasSuffix("]") {
            primaryType = String(primaryType[..<indexOfOpenBracket])
        }
        let primaryTypes_ = types[primaryType]
        guard !found.contains(primaryType),let primaryTypes = primaryTypes_ else {
            return found
        }
        found.insert(primaryType)
        for type in primaryTypes {
            findDependencies(primaryType: type.type, dependencies: found)
                .forEach { found.insert($0) }
        }
        return found
    }

    /// Encode a type of struct
    func encodeType(primaryType: String) -> Data {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        let encoded: String = sorted.compactMap { type in
            guard let values = types[type] else { return nil }
            let param = values.map { "\($0.type) \($0.name)" }.joined(separator: ",")
            return "\(type)(\(param))"
        }.joined()
        return encoded.data(using: .utf8) ?? Data()
    }
    
    func checkTypeParam(primaryType: String) -> Bool {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        for subType in sorted {
            guard let values = types[subType] else { return false }
            for subValue in values {
                let result = self.validateStructuredData(type: subValue.type, param: subValue.name)
                if result == false {
                    return result
                }
            }
        }
        return true
    }
    
    /// valid EIP712 JSON Struct
    func validateStructuredData(type: String,param: String) -> Bool {
        var result = true
        //check name
        let identifierPredicate = NSPredicate.init(format: "SELF MATCHES %@", identifierPattern)
        if !identifierPredicate.evaluate(with: param) {
            result = false
        }
        
        //check type
        let typePredicate = NSPredicate.init(format: "SELF MATCHES %@", typePattern)
        if !typePredicate.evaluate(with: type) {
            result = false
        }
        
        if type.starts(with: "int") && type.index(of: "[") == nil {
            let size = parseIntSize(type: type, prefix: "int")
            guard size > 0 && size <= 256 else {
                return false
            }
        }
        
        if type.starts(with: "uint") && type.index(of: "[") == nil {
            let size = parseIntSize(type: type, prefix: "uint")
            guard size > 0 && size <= 256 else {
                return false
            }
        }
        
        return result
    }
    
    func encodeTypeString(primaryType: String) -> String {
        var depSet = findDependencies(primaryType: primaryType)
        depSet.remove(primaryType)
        let sorted = [primaryType] + Array(depSet).sorted()
        let encoded: String = sorted.compactMap { type in
            guard let values = types[type] else { return nil }
            let param = values.map { "\($0.type) \($0.name)" }.joined(separator: ",")
            return "\(type)(\(param))"
        }.joined()
        return encoded
    }

    /// Encode an instance of struct
    ///
    /// Implemented with `ABIEncoder` and `ABIValue`
    func encodeData(data: JSON, type: String) throws -> Data {
        let encoder = ABIEncoder()
        var values: [ABIValue] = []
        guard let valueTypes = types[type],
              let object = data.objectValue,
              object.count == valueTypes.count,
              Set(object.keys) == Set(valueTypes.map { $0.name }) else {
            throw EIP712Error.TypeParamError("missing eip712 type: \(type)")
        }
        for field in valueTypes {
            guard let value = data[field.name],
                  let encoded = try encodeField(value: value, type: field.type) else {
                throw EIP712Error.TypeParamError("invalid eip712 field: \(type).\(field.name)")
            }
            values.append(encoded)
        }
        try encoder.encode(tuple: values)
        return encoder.data
    }
    
    func encodeField(value: JSON, type: String) throws -> ABIValue? {
        if isStruct(type) {
            let nestEncoded = try hashStruct(value, type: type)
            return try ABIValue(nestEncoded, type: .bytes(32))
        } else if type.hasSuffix("]"), let indexOfLastBracket = type.lastIndex(of: "["), case let .array(elements) = value {
            var encodedElements: Data = .init()
            // Strip only the trailing dimension: the element type of `T[][]` is `T[]`, not `T`.
            // Using the first "[" collapsed every dimension at once, which made nested arrays
            // either throw (basic types) or hash against the wrong type (struct types).
            let elementType = String(type[..<indexOfLastBracket])
            // A fixed-size array `T[N]` must carry exactly N elements; a dynamic `T[]` has
            // an empty dimension and accepts any count.
            let dimension = type[type.index(after: indexOfLastBracket)..<type.index(before: type.endIndex)]
            if !dimension.isEmpty {
                guard let declaredCount = Int(dimension), declaredCount == elements.count else {
                    throw EIP712Error.TypeParamError("eip712 fixed-size array length mismatch! type = \(type), actual count = \(elements.count)")
                }
            }
            for each in elements {
                guard let value = try encodeField(value: each, type: elementType) else {
                    throw EIP712Error.TypeParamError("invalid eip712 array element: \(elementType)")
                }
                let encoder = ABIEncoder()
                try encoder.encode(value)
                encodedElements += encoder.data
            }
            return try ABIValue(Crypto.hash(encodedElements), type: .bytes(32))
        } else if let value = try makeABIValue(data: value, type: type) {
            return value
        } else {
            return nil
        }
    }

    /// Helper func for `encodeData`
    /// Bytes and string types will be hashed with keccak256
    /// Array is processed by encodeData first, and then keccak256 hashed
    private func makeABIValue(data: JSON?, type: String) throws -> ABIValue? {
        if type == "string", let value = data?.stringValue, let valueData = value.data(using: .utf8) {
            return try ABIValue(Crypto.hash(valueData), type: .bytes(32))
        } else if type == "bytes", let value = data?.stringValue {
            guard let valueData = Data(hexString: value) else {
                throw EIP712Error.TypeParamError("invalid eip712 bytes hex")
            }
            return try ABIValue(Crypto.hash(valueData), type: .bytes(32))
        } else if type == "bool", let value = data?.boolValue {
            return try ABIValue(value, type: .bool)
        } else if type == "address", let value = data?.stringValue {
            // The pinned TLCore converter calls its own Base58 validator. Bound
            // input here too: 34-byte Base58 or up to 44-byte prefixed TRON hex.
            // EVM's 40/42-byte forms keep the existing conversion below.
            guard value.utf8.prefix(45).count <= 44 else {
                throw EIP712Error.TypeParamError("eip712 type value error! type = address")
            }
            let addressString = value.convertEIP712TronAddress()
            let address = Address(string: addressString)
            if let checkAddress = address {
                return try ABIValue(checkAddress, type: .address)
            }
        } else if type.starts(with: "uint") || type.lowercased() == "trctoken" {
            var size = parseIntSize(type: type, prefix: "uint")
            if type.lowercased() == "trctoken" {
                size = 256
            }
            guard size > 0 && size <= 256 else {
                throw EIP712Error.TypeParamError("eip712 integer width error! type = \(type)")
            }
            if let value = integerString(from: data),
               let bigInt = BigUInt(value: value) {
                return try ABIValue(bigInt, type: .uint(bits: size))
            }
        } else if type.starts(with: "int") {
            let size = parseIntSize(type: type, prefix: "int")
            guard size > 0 && size <= 256 else {
                throw EIP712Error.TypeParamError("eip712 integer width error! type = \(type)")
            }
            if let value = integerString(from: data),
               let bigInt = BigInt(value: value) {
                return try ABIValue(bigInt, type: .int(bits: size))
            }
        } else if type.starts(with: "bytes") {
            if let length = Int(type.dropFirst("bytes".count)), let value = data?.stringValue {
                if value.starts(with: "0x") {
                    guard let hex = Data(hexString: value) else {
                        throw EIP712Error.TypeParamError("invalid eip712 fixed bytes hex")
                    }
                    return try ABIValue(hex, type: .bytes(length))
                } else {
                    return try ABIValue(Data(bytes: Array(value.utf8)), type: .bytes(length))
                }
            }
        }
        throw EIP712Error.TypeParamError("eip712 type value error! type = \(type)")
    }

    private func integerString(from data: JSON?) -> String? {
        guard let data = data else { return nil }
        switch data {
        case .string(let value):
            return value
        case .number(let value):
            return value.integerString
        case .array, .object, .bool, .null:
            return nil
        }
    }

    /// Helper func for encoding uint / int types
    private func parseIntSize(type: String, prefix: String) -> Int {
        guard type.starts(with: prefix),
            let size = Int(type.dropFirst(prefix.count)) else {
            return -1
        }

        if size < 8 || size > 256 || size % 8 != 0 {
            return -1
        }
        return size
    }

    private func isStruct(_ fieldType: String) -> Bool {
        types[fieldType] != nil
    }

    func hashStruct(_ data: JSON, type: String) throws -> Data {
        let encodeType = typeHash(type)
        let encodeData = try encodeData(data: data, type: type)
        return Crypto.hash(encodeType + encodeData)
    }

    func typeHash(_ type: String) -> Data {
        return Crypto.hash(encodeType(primaryType: type))
    }
}

private extension EIP712TypedData.NumberValue {
    var integerString: String? {
        switch self {
        case .int(let value):
            return String(value)
        case .double(let value):
            guard value.isFinite,
                  value.rounded(.towardZero) == value,
                  abs(value) <= 9_007_199_254_740_991 else {
                return nil
            }
            if value == 0 {
                return "0"
            }
            return String(format: "%.0f", value)
        }
    }
}

private extension BigInt {
    init?(value: String) {
        if value.lowercased().starts(with: "0x") {
            self.init(String(value.dropFirst(2)), radix: 16)
        } else {
            self.init(value)
        }
    }
}

private extension BigUInt {
    init?(value: String) {
        if value.lowercased().starts(with: "0x") {
            self.init(String(value.dropFirst(2)), radix: 16)
        } else {
            self.init(value)
        }
    }
}

class Crypto {
    static func hash(_ data: Data) -> Data {
        return data.sha3(.keccak256)
    }
}
