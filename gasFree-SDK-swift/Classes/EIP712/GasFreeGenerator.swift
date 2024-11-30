import Foundation
import TLCore
import web3swift
import TronKeystore
import TronCore

enum TronLinkGasfreeEnv {
    case nile
    case shasta 
    case online
    
    var chainId: Int {
        switch self {
        case .nile:
            return Int("cd8690dc",radix: 16) ?? 0
        case .shasta:
            return Int("94a9059e",radix: 16) ?? 0
        case .online:
            return Int("2b6653dc",radix: 16) ?? 0
        }
    }
    
    var verifyingContract: String {
        switch self {
        case .nile:
            return "TNtzqaE9p23tzpN1SHavUCCuzSwrzbHEHE"
        case .shasta:
            return "TJv8NsQPKBWLFTSQXMVBBnirTuutaPWTtu"
        case .online:
            return ""
        }
    }
}

class GasfreeTransactionParamModel: NSObject,Codable {
    var token: String?
    var provider: String?
    var user: String?
    var receiver: String?
    var value: String?
    var maxFee: String?
    var deadline: Int64?
    var version: Int64?
    var nonce: Int64?
    var sig: String?
}


class GasFreeGenerator: NSObject {
    @objc static let shareManager = GasFreeGenerator()

    let gasfreeJSON = """
        {
            "domain": {
                "chainId": 3448148188,
                "name": "GasFreeController",
                "verifyingContract": "TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g",
                "version": "V1.0.0"
            },
            "message": {
                "token": "0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F",
                "serviceProvider": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                "user": "0x70C77E8aC165d2980E9741cB4Af2E40cF3C280de",
                "receiver": "0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc",
                "value": 1000,
                "maxFee": 10000,
                "deadline": 1726820009,
                "version": 1,
                "nonce": 0
            },
            "primaryType": "PermitTransfer",
            "types": {
                "PermitTransfer": [{
                    "name": "token",
                    "type": "address"
                }, {
                    "name": "serviceProvider",
                    "type": "address"
                }, {
                    "name": "user",
                    "type": "address"
                }, {
                    "name": "receiver",
                    "type": "address"
                }, {
                    "name": "value",
                    "type": "uint256"
                }, {
                    "name": "maxFee",
                    "type": "uint256"
                }, {
                    "name": "deadline",
                    "type": "uint256"
                }, {
                    "name": "version",
                    "type": "uint256"
                }, {
                    "name": "nonce",
                    "type": "uint256"
                }],
                "EIP712Domain": [{
                    "name": "name",
                    "type": "string"
                }, {
                    "name": "version",
                    "type": "string"
                }, {
                    "name": "chainId",
                    "type": "uint256"
                }, {
                    "name": "verifyingContract",
                    "type": "address"
                }]
            }
        }
        """
    
    let preHexUInt: UInt8 = 0x41  // tron = 0x41，eth = 0xff
    
    var user = ""
    let gasFreeFactoryAddress = "TNtzqaE9p23tzpN1SHavUCCuzSwrzbHEHE"
    let beaconAddress = "THoYa62ZAqjPGsmFygxx3dLqCHyVbT2VBZ";
    let creationCodeStr = "60a06040908082526104b8803803809161001982856102a9565b833981019082818303126102a557610030816102e0565b91602091828101519060018060401b0382116102a5570181601f820112156102a55780519061005e826102fd565b9261006b875194856102a9565b8284528483830101116102a55783905f5b8381106102915750505f9183010152823b15610271577fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d5080546001600160a01b0319166001600160a01b038581169182179092558551635c60da1b60e01b8082529193928582600481885afa918215610267575f92610230575b50813b156102175750508551837f1cf3b03a6cf19fa2baba4df148e9dcabedea7f8a5c07840e207e5c089be95d3e5f80a28251156101f857508390600487518095819382525afa9182156101ee575f926101ab575b50905f8083856101889695519101845af4903d156101a2573d61016d816102fd565b9061017a885192836102a9565b81525f81943d92013e610318565b505b6080525161013c908161037c82396080518160180152f35b60609250610318565b90918382813d83116101e7575b6101c281836102a9565b810103126101e45750905f806101db61018895946102e0565b9394505061014b565b80fd5b503d6101b8565b85513d5f823e3d90fd5b935050505034610208575061018a565b63b398979f60e01b8152600490fd5b8751634c9c8ce360e01b81529116600482015260249150fd5b90918682813d8311610260575b61024781836102a9565b810103126101e45750610259906102e0565b905f6100f6565b503d61023d565b88513d5f823e3d90fd5b8351631933b43b60e21b81526001600160a01b0384166004820152602490fd5b81810183015185820184015285920161007c565b5f80fd5b601f909101601f19168101906001600160401b038211908210176102cc57604052565b634e487b7160e01b5f52604160045260245ffd5b516001600160a81b03811681036102a5576001600160a01b031690565b6001600160401b0381116102cc57601f01601f191660200190565b9061033f575080511561032d57805190602001fd5b604051630a12f52160e11b8152600490fd5b81511580610372575b610350575090565b604051639996b31560e01b81526001600160a01b039091166004820152602490fd5b50803b1561034856fe60806040819052635c60da1b60e01b81526020816004817f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03165afa9081156100ae575f91610056575b506100e8565b6020903d82116100a6575b601f8201601f1916810167ffffffffffffffff8111828210176100925761008c9350604052016100b9565b5f610050565b634e487b7160e01b84526041600452602484fd5b3d9150610061565b6040513d5f823e3d90fd5b602090607f1901126100e4576080516001600160a81b03811681036100e4576001600160a01b031690565b5f80fd5b5f808092368280378136915af43d82803e15610102573d90f35b3d90fdfea26474726f6e58221220b3a0a0f4043f8fe355d62319dafed2ba5d611d7bb6dfe21d6d935af1510ce27964736f6c63430008140033";
    
    // MARK: GasFree EIP712 Hash Generate
    private func createSigner712Struct(chainId:Int, verifyingContract:String, messageModel:GasfreeTransactionParamModel) -> NSMutableDictionary?{
        if let data = gasfreeJSON.data(using:.utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = jsonObject as? [String: Any] {
                    let mutableDictionary = NSMutableDictionary(dictionary: dictionary)
                    if var domain = mutableDictionary["domain"] as? [String: Any] {
                        domain["chainId"] = chainId
                        domain["verifyingContract"] = verifyingContract
                        mutableDictionary["domain"] = domain
                    }
                    if var message = mutableDictionary["message"] as? [String: Any] {
                        message["token"] = self.getEthereumAdress(tronAddress: messageModel.token ?? "")
                        message["serviceProvider"] = self.getEthereumAdress(tronAddress: messageModel.provider ?? "")
                        message["user"] = self.getEthereumAdress(tronAddress: messageModel.user ?? "")
                        message["receiver"] = self.getEthereumAdress(tronAddress: messageModel.receiver ?? "")
                        message["value"] = messageModel.value
                        message["maxFee"] = messageModel.maxFee
                        message["deadline"] = messageModel.deadline
                        message["nonce"] = messageModel.nonce
                        message["version"] = messageModel.version
                        mutableDictionary["message"] = message
                    }
                    return mutableDictionary
                }
            } catch {
                print("Error converting JSON to dictionary: \(error)")
            }
        }
        return nil
    }
    
    func permitTransferMessageHash(env: TronLinkGasfreeEnv, messageModel:GasfreeTransactionParamModel) -> String {
        let chainId = Int(env.chainId)
        let verifyingContract = env.verifyingContract
        if let gasFreedic = self.createSigner712Struct(chainId: chainId,verifyingContract: verifyingContract, messageModel: messageModel) {
            do {
                let gasFreeData = try JSONSerialization.data(withJSONObject: gasFreedic, options: [])
                let typed = try JSONDecoder().decode(EIP712TypedData.self, from: gasFreeData)
                let finallyHash = try typed.signHash()
                return finallyHash.hexEncoded
            } catch {
                print("Error converting dictionary to data: \(error)")
            }
        }
        return ""
    }

    func permitTransferMessageHash(gasfreeJSONString:String) -> String {
        if let gasFreeData = gasfreeJSONString.data(using: .utf8) {
            do {
                let typed = try JSONDecoder().decode(EIP712TypedData.self, from: gasFreeData)
                let finallyHash = try typed.signHash()
                return finallyHash.hexEncoded
            } catch {
                print("Error converting dictionary to data: \(error)")
            }
        }
        return ""
    }
    
    
    func getEthereumAdress(tronAddress: String) -> String {
        let address = tronAddress.convertTronAddressToBase58HexAddress()
        if address.hasPrefix("41") {
            return String(address.dropFirst(2)).add0x
        }
        return address
    }
    
    // MARK: GasFree Address Generate
    func generateAddress(userAddress: String) -> String {
        if userAddress.isEmpty {
            return ""
        }
        self.user = userAddress
        
        let salt = self.getByte32(base58Data: self.user.base58CheckData)
        let creationCode = self.creationCodeStr.hexStringToUTF8Data()
        let beacon = self.getByte32(base58Data: self.beaconAddress.base58CheckData)
        
        guard let _ = self.user.base58CheckData,
              let _ = creationCode,
              let _ = self.beaconAddress.base58CheckData else {
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
        mergeData.append(self.preHexUInt)
        mergeData.append(self.base58CheckDecodeRemove41(address: self.gasFreeFactoryAddress))
        mergeData.append(salt)
        mergeData.append(bytecodeHash)
        let mergeDataSha3 = mergeData.sha3(.keccak256)
        let gasFreeAddressByte = self.getAddressByte(byte32: mergeDataSha3)
        
        let gasFreeAddress = String(base58CheckEncoding: gasFreeAddressByte)
        return gasFreeAddress
    }
    
    func getByte32(base58Data: Data?) -> Data {
        var bytes32 = Data()
        if let data = base58Data, data.bytesT.count > 1 {
            var bytes = data.bytesT[1..<data.bytesT.count]
            while bytes.count < 32 {
                bytes.insert(0, at: 1)
            }
            
            bytes32 = Data.init(bytes: bytes)
        }
        return bytes32
    }
    
    func base58CheckDecodeRemove41(address: String) -> Data {
        guard let data = address.base58CheckData, data.count > 1 else {
            return Data()
        }
        let bytes = data[1..<data.count]
        return bytes
    }
    

    func getAddressByte(byte32: Data) -> Data {
        var resultData = Data()
        if byte32.count > 12 {
            resultData.append(self.preHexUInt)
            let addressByte = byte32[12..<byte32.count]
            resultData.append(addressByte)
        }
        return resultData
    }
    
}

