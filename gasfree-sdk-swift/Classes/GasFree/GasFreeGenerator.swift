import Foundation
import TLCore
import web3swift
import TronKeystore
import TronCore

enum GasFreeGeneratorError: Error {
    case invalidToken
    case invalidUser
    case invalidReceiver
    case invalidServiceProvider
    case jsonDecodeError(Error)
    case jsonConversionError(Error)
    case invalidJSONString

    var localizedDescription: String {
        switch self {
        case .invalidToken:
            return "Invalid message, token should be a valid Tron Address"
        case .invalidUser:
            return "Invalid message, user should be a valid Tron Address"
        case .invalidReceiver:
            return "Invalid message, receiver should be a valid Tron Address"
        case .invalidServiceProvider:
            return "Invalid message, serviceProvider should be a valid Tron Address"
        case .jsonDecodeError(let error):
            return "Error json decode: \(error)"
        case .jsonConversionError(let error):
            return "Error converting data to json: \(error)"
        case .invalidJSONString:
            return "Invalid JSON string"
        }
    }
}

class GasFreeGenerator: NSObject {
    @objc static let shareManager = GasFreeGenerator()
    
    // MARK: GasFree Message Hash Generate
    func permitTransferMessageHash(chainId: String,
                                   verifyingContract: String,
                                   token: String,
                                   serviceProvider: String,
                                   user: String,
                                   receiver: String,
                                   value: String,
                                   maxFee: String,
                                   deadline: Int64,
                                   version: Int64,
                                   nonce: Int64) throws -> String {
        
        let gasFreedic = GasFreeCommon.createSigner712Struct(chainId: chainId, verifyingContract: verifyingContract, token: token, serviceProvider: serviceProvider, user: user, receiver: receiver, value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: gasFreedic ?? [:], options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            let messageHash = try self.permitTransferMessageHash(gasfreeJSONString: jsonString)
            return messageHash
        } catch {
            throw GasFreeGeneratorError.jsonConversionError(error)
        }
    }
      
    func permitTransferMessageHash(gasfreeJSONString: String) throws -> String {
        if let gasFreeData = gasfreeJSONString.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: gasFreeData, options: [])
                if let dictionary = jsonObject as? [String: Any], let message = dictionary["message"] as? [String: Any] {
                    
                    guard let token = message["token"] as? String, token.isTRXAddress() else {
                        throw GasFreeGeneratorError.invalidToken
                    }
                    
                    guard let user = message["user"] as? String, user.isTRXAddress() else {
                        throw GasFreeGeneratorError.invalidUser
                    }
                    guard let receiver = message["receiver"] as? String, receiver.isTRXAddress() else {
                        throw GasFreeGeneratorError.invalidReceiver
                    }
                    guard let serviceProvider = message["serviceProvider"] as? String, serviceProvider.isTRXAddress() else {
                        throw GasFreeGeneratorError.invalidServiceProvider
                    }
                    do {
                        let typed = try JSONDecoder().decode(EIP712TypedData.self, from: gasFreeData)
                        let finallyHash = try typed.signHash()
                        return finallyHash.hexEncoded
                    } catch {
                        throw GasFreeGeneratorError.jsonDecodeError(error)
                    }
                }
            } catch {
                throw GasFreeGeneratorError.jsonConversionError(error)
            }
        }
        throw GasFreeGeneratorError.invalidJSONString
    }
    
    // MARK: GasFree Address Generate
    func generateGasFreeAddress(chainId: String, userAddress: String) -> String {
        let env = GasFreeCommon.getCurrentEnv(chainId: chainId)
        let gasfreeAddress = self.generateGasFreeAddress(userAddress: userAddress, gasFreeFactoryAddress: env.verifyingContract, beaconAddress: env.beaconAddress, creationCodeStr: env.creationCode)
        return gasfreeAddress
    }
    
    func generateGasFreeAddress(userAddress: String, gasFreeFactoryAddress: String, beaconAddress: String, creationCodeStr: String) -> String {
        if userAddress.isEmpty {
            return ""
        }
        let user = userAddress
        
        let salt = GasFreeCommon.getByte32(base58Data: user.base58CheckData)
        let creationCode = creationCodeStr.hexStringToUTF8Data()
        let beacon = GasFreeCommon.getByte32(base58Data: beaconAddress.base58CheckData)
        
        guard let _ = user.base58CheckData,
              let _ = creationCode,
              let _ = beaconAddress.base58CheckData else {
            return ""
        }
                        
        /**
         abi.encodeCall("initialize", (user))
         **/
        let user_address_param = TronCore.Address.init(data: salt)
        let function = Function(name: "initialize", parameters: [.address])
        let encodeCall = ABIEncoder()
        try! encodeCall.encode(function: function, arguments: [user_address_param])
        
        /**
         abi.encode(
                    beacon,
                    GasFreeFactory,
                    abi.encodeCall("initialize", (user))
                 )
         **/
        let beacon_address_param = TronCore.Address.init(data: beacon)
        let beacon_ABIValue = try! ABIValue.init(beacon_address_param, type: .address)
        let encodeCall_ABIValue = try! ABIValue.init(encodeCall.data, type: .dynamicBytes)
        let encode = ABIEncoder()
        try! encode.encode(tuple: [beacon_ABIValue, encodeCall_ABIValue])
        
        /**
         bytecodeHash :
         byte[32] bytecodeHash =  keccak256 (
                                       abi.encodePacked ( creationCode,
                                                      abi.encode (
                                                               beacon,
                                                               GasFreeFactory,
                                                               abi.encodeCall("initialize", (user))
                                                               )
                                                     )
                                      )
         **/
        var encodePackedData = Data()
        encodePackedData.append(creationCode!)
        encodePackedData.append(encode.data)
        let bytecodeHash = encodePackedData.sha3(.keccak256)
        
        /**
         GasFreeAddress = keccak256(
         bytes.merge(
         bytes("0x41") ,
         bytes(GasFreeFactory),
         salt,
         byteCodeHash
         ) )
         **/
        var mergeData = Data()
        mergeData.append(GasfreeConfig.preHexUInt)
        mergeData.append(GasFreeCommon.base58CheckDecodeRemove41(address: gasFreeFactoryAddress))
        mergeData.append(salt)
        mergeData.append(bytecodeHash)
        let mergeDataSha3 = mergeData.sha3(.keccak256)
        let gasFreeAddressByte = GasFreeCommon.getAddressByte(byte32: mergeDataSha3)
        
        let gasFreeAddress = String(base58CheckEncoding: gasFreeAddressByte)
        return gasFreeAddress
    }

}

