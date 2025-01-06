import Foundation
import BigInt
import TronCore
import CryptoSwift
import TLCore


let identifierPattern = "^[a-zA-Z_$][a-zA-Z_$0-9]*$"
let typePattern = "^[a-zA-Z_$][a-zA-Z_$0-9]*(\\[([1-9]\\d*)*\\])*$"

enum EIP712Error: Error{
    case TypeParamError (String)
    case OtherError (String)
}

extension EIP712TypedData {
    /// Sign-able hash for an `EIP712TypedData`
    func signHash() throws -> Data {
        var domainKey = "EIP712Domain"
        for typeKey in types.keys {
            if typeKey.lowercased().contains("domain") {
                domainKey = typeKey
                break
            }
        }
        let domainData = try hashStruct(domain, type: domainKey)
        let messageData = try hashStruct(message, type: primaryType)
        let data = Data(bytes: [0x19, 0x01]) + domainData + messageData
        return Crypto.hash(data)
    }
    
    func signEip712Hash() throws -> (hashData: Data,domainData: Data,messageData: Data) {
        var domainKey = "EIP712Domain"
        for typeKey in types.keys {
            if typeKey.lowercased().contains("domain") {
                domainKey = typeKey
                break
            }
        }
        let domainData = try hashStruct(domain, type: domainKey)
        let messageData = try hashStruct(message, type: primaryType)
        let data = Data(bytes: [0x19, 0x01]) + domainData + messageData
        return (Crypto.hash(data), domainData, messageData)
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
        let encoded = sorted.compactMap { type in
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
        let encoded = sorted.compactMap { type in
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
        if let valueTypes = types[type] {
            for field in valueTypes {
                guard let value = data[field.name] else { continue }
                if let encoded = try encodeField(value: value, type: field.type) {
                    self.testABIEncodeHexString(value: encoded, type: field.type)
                    values.append(encoded)
                }
            }
        }
        try encoder.encode(tuple: values)
        return encoder.data
    }
    
    func testABIEncodeHexString(value:ABIValue,type:String) {
        let encoder = ABIEncoder()
        do {
            try encoder.encode(tuple: [value])
        } catch let error {
            print("Error ABIEncode: \(error)")
        }
        let hexstring = encoder.data.hexString
    }

    func encodeField(value: JSON, type: String) throws -> ABIValue? {
        if isStruct(type) {
            let nestEncoded = try hashStruct(value, type: type)
            return try ABIValue(nestEncoded, type: .bytes(32))
        } else if let indexOfOpenBracket = type.index(of: "["), type.hasSuffix("]"), case let .array(elements) = value {
            var encodedElements: Data = .init()
            let elementType = String(type[..<indexOfOpenBracket])
            for each in elements {
                if let value = try encodeField(value: each, type: elementType) {
                    let encoder = ABIEncoder()
                    try encoder.encode(value)
                    encodedElements += encoder.data
                }
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
            return try? ABIValue(Crypto.hash(valueData), type: .bytes(32))
        } else if type == "bytes", let value = data?.stringValue {
            var valueData = value.drop0x.hexStringToData() ?? Data.init()
            if value == "0x" {
                valueData = Data.init(hex: value.drop0x)
            }
            return try? ABIValue(Crypto.hash(valueData), type: .bytes(32))
        } else if type == "bool", let value = data?.boolValue {
            return try? ABIValue(value, type: .bool)
        } else if type == "address", let value = data?.stringValue {
            let addressString = value.convertEIP712TronAddress()
            let address = Address(string: addressString)
            if let checkAddress = address {
                return try? ABIValue(checkAddress, type: .address)
            }
        } else if type.starts(with: "uint") || type.lowercased() == "trctoken" {
            var size = parseIntSize(type: type, prefix: "uint")
            if type.lowercased() == "trctoken" {
                size = 256
            }
            guard size > 0 && size <= 256 else {
                return nil
            }
            if let numberValue = data?.numberValue {
                switch numberValue {
                case let .int(value):
                    return try? ABIValue(value, type: .uint(bits: size))
                case let .double(value):
                    return try? ABIValue(Int(value), type: .uint(bits: size))
                }
            } else if let value = data?.stringValue,
                      let bigInt = BigUInt(value: value) {
                return try? ABIValue(bigInt, type: .uint(bits: size))
            }
        } else if type.starts(with: "int") {
            let size = parseIntSize(type: type, prefix: "int")
            guard size > 0 && size <= 256 else {
                return nil
            }
            if let numberValue = data?.numberValue {
                switch numberValue {
                case let .int(value):
                    return try? ABIValue(value, type: .int(bits: size))
                case let .double(value):
                    return try? ABIValue(Int(value), type: .int(bits: size))
                }
            } else if let value = data?.stringValue,
                      let bigInt = BigInt(value: value) {
                return try? ABIValue(bigInt, type: .int(bits: size))
            }
        } else if type.starts(with: "bytes") {
            if let length = Int(type.dropFirst("bytes".count)), let value = data?.stringValue {
                if value.starts(with: "0x") {
                    var hex = value.drop0x.hexStringToData() ?? Data.init()
                    if value == "0x" {
                        hex = Data.init(hex: value.drop0x)
                    }
                    return try? ABIValue(hex, type: .bytes(length))
                } else {
                    return try? ABIValue(Data(bytes: Array(value.utf8)), type: .bytes(length))
                }
            }
        }
        throw EIP712Error.TypeParamError("eip712 type value error! type = \(type)")
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

private extension BigInt {
    init?(value: String) {
        if value.starts(with: "0x") {
            self.init(String(value.dropFirst(2)), radix: 16)
        } else {
            self.init(value)
        }
    }
}

private extension BigUInt {
    init?(value: String) {
        if value.starts(with: "0x") {
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

extension String {
    var base58CheckData: Data? {
        return Data(base58CheckDecoding: self)
    }
    
    func isEIP712TronAddress() -> Bool {
        if self.hasPrefix("T") || self.hasPrefix("41") {
            return true
        }
        return false
    }
    
    func convertEIP712TronAddress() -> String {
        var currentAddress = self
        if isEIP712TronAddress() {
            if currentAddress.hasPrefix("T") {
                currentAddress = currentAddress.base58CheckData?.toHexString() ?? ""
            }
            currentAddress = String(currentAddress.dropFirst("41".count))
        }else if currentAddress.hasPrefix("0x") {
            currentAddress = String(currentAddress.dropFirst("0x".count))
        }
        return currentAddress
    }
    
    
    func hexStringToData() -> Data? {
        guard !self.isEmpty else {
            return nil
        }
        
        var hexData = Data(capacity: 20)
        var range: NSRange
        
        if self.count % 2 == 0 {
            range = NSRange(location: 0, length: 2)
        } else {
            range = NSRange(location: 0, length: 1)
        }
        
        var location = range.location
        while location < self.count {
            let hexCharStr = (self as NSString).substring(with: range)
            var value: UInt32 = 0
            Scanner(string: hexCharStr).scanHexInt32(&value)
            var byte = UInt8(value)
            hexData.append(&byte, count: 1)
            
            location += range.length
            range.location = location
            range.length = 2
        }
        
        return hexData
    }
}

extension Data {
    init?(base58CheckDecoding string: String, alphabet: [UInt8] = Base58String.btcAlphabet) {
        
        let data = Data(base58Decoding: string)
        guard let decodeCheck = data, decodeCheck.count >= 4 else {
            return nil
        }
        let decodeData = decodeCheck.subdata(in: 0..<(decodeCheck.count - 4))
        let hash0 = decodeData.sha256T()
        let hash1 = hash0.sha256T()
        if hash1[0] == decodeCheck[decodeData.count] && hash1[1] == decodeCheck[decodeData.count + 1] && hash1[2] == decodeCheck[decodeData.count + 2] && hash1[3] == decodeCheck[decodeData.count + 3] {
            self = decodeData
        } else {
            return nil
        }
    }
}
