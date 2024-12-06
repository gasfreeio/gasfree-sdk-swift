import Foundation
import TLCore
import web3swift
import TronKeystore
import TronCore


class GasFreeGenerator: NSObject {
    @objc static let shareManager = GasFreeGenerator()
    
    var user = ""    
    // MARK: GasFree Message Hash Generate
    func permitTransferMessageHash(gasfreeJSONString:String) -> String {
        if let gasFreeData = gasfreeJSONString.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: gasFreeData, options: [])
                if let dictionary = jsonObject as? [String: Any],  let message = dictionary["message"] as? [String: Any] {
                    
                    guard let token = message["token"] as? String, token.isTRXAddress() else {
                        print("Invalid message, token should be a valid Tron Address")
                        return ""
                    }
                    
                    guard let user = message["user"] as? String, user.isTRXAddress() else {
                        print("Invalid message, user should be a valid Tron Address")
                        return ""
                    }
                    guard let receiver = message["receiver"] as? String, receiver.isTRXAddress() else {
                        print("Invalid message, receiver should be a valid Tron Address")
                        return ""
                    }
                    guard let serviceProvider = message["serviceProvider"] as? String, serviceProvider.isTRXAddress() else {
                        print("Invalid message, serviceProvider should be a valid Tron Address")
                        return ""
                    }
                    do {
                        let typed = try JSONDecoder().decode(EIP712TypedData.self, from: gasFreeData)
                        let finallyHash = try typed.signHash()
                        return finallyHash.hexEncoded
                    } catch {
                        print("Error json decode: \(error)")
                    }
                }
            } catch {
                print("Error converting data to json: \(error)")
            }
        }
        return ""
    }
    
    // MARK: GasFree Address Generate
    func generateGasFreeAddress(chainId: String, userAddress: String) -> String {
        
        let env = GasFreeCommon.getCurrentEnv(chainId: chainId)
        if userAddress.isEmpty {
            return ""
        }
        self.user = userAddress
        
        let salt = GasFreeCommon.getByte32(base58Data: self.user.base58CheckData)
        let creationCode = env.creationCode.hexStringToUTF8Data()
        let beacon = GasFreeCommon.getByte32(base58Data: env.beaconAddress.base58CheckData)
        
        guard let _ = self.user.base58CheckData,
              let _ = creationCode,
              let _ = env.beaconAddress.base58CheckData else {
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
        mergeData.append(TronLinkGasfreeConfig.preHexUInt)
        mergeData.append(GasFreeCommon.base58CheckDecodeRemove41(address: env.verifyingContract))
        mergeData.append(salt)
        mergeData.append(bytecodeHash)
        let mergeDataSha3 = mergeData.sha3(.keccak256)
        let gasFreeAddressByte = GasFreeCommon.getAddressByte(byte32: mergeDataSha3)
        
        let gasFreeAddress = String(base58CheckEncoding: gasFreeAddressByte)
        return gasFreeAddress
    }
}

