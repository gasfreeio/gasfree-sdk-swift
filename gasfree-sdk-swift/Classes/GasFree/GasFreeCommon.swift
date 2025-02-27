import Foundation

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

struct TronLinkGasfreeConfig {
    
    static let nile_chainId = "0xcd8690dc"
    static let shasta_chainId = "0x94a9059e"
    static let mainnet_chainId = "0x2b6653dc"
     
    static let nile_verifyingContract = "THQGuFzL87ZqhxkgqYEryRAd7gqFqL5rdc"
    static let shasta_verifyingContract = "TQghdCeVDA6CnuNVTUhfaAyPfTetqZWNpm"
    static let mainnet_verifyingContract = "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U"
    
    static let nile_beaconAddress = "TLtCGmaxH3PbuaF6kbybwteZcHptEdgQGC"
    static let shasta_beaconAddress = "TQ1jvA3nLDMDNbJoMPLzTPoqAg8NvZ5CCW"
    static let mainnet_beaconAddress = "TSP9UW6FQhT76XD2jWA6ipGMx3yGbjDffP"

    static let preHexUInt: UInt8 = 0x41  // tron = 0x41，eth = 0xff
    static let test_creationCodeStr = "0x60a06040908082526103e5803803809161001982856101d6565b833981019082818303126101d2576100308161020d565b91602091828101519060018060401b0382116101d2570181601f820112156101d25780519061005e8261022a565b9261006b875194856101d6565b8284528483830101116101d25783905f5b8381106101be5750505f9183010152823b1561017a5780516100b3575b50506080525161013c90816102a982396080518160180152f35b8351635c60da1b60e01b81529082826004816001600160a01b0388165afa918215610170575f9261012d575b50905f80838561011c9695519101845af4903d15610124573d6101018161022a565b9061010e885192836101d6565b81525f81943d92013e610245565b505f80610099565b60609250610245565b90918382813d8311610169575b61014481836101d6565b810103126101665750905f8061015d61011c959461020d565b939450506100df565b80fd5b503d61013a565b85513d5f823e3d90fd5b835162461bcd60e51b815260048101839052601b60248201527f626561636f6e2073686f756c64206265206120636f6e747261637400000000006044820152606490fd5b81810183015185820184015285920161007c565b5f80fd5b601f909101601f19168101906001600160401b038211908210176101f957604052565b634e487b7160e01b5f52604160045260245ffd5b516001600160a81b03811681036101d2576001600160a01b031690565b6001600160401b0381116101f957601f01601f191660200190565b9061026c575080511561025a57805190602001fd5b604051630a12f52160e11b8152600490fd5b8151158061029f575b61027d575090565b604051639996b31560e01b81526001600160a01b039091166004820152602490fd5b50803b1561027556fe60806040819052635c60da1b60e01b81526020816004817f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03165afa9081156100ae575f91610056575b506100e8565b6020903d82116100a6575b601f8201601f1916810167ffffffffffffffff8111828210176100925761008c9350604052016100b9565b5f610050565b634e487b7160e01b84526041600452602484fd5b3d9150610061565b6040513d5f823e3d90fd5b602090607f1901126100e4576080516001600160a81b03811681036100e4576001600160a01b031690565b5f80fd5b5f808092368280378136915af43d82803e15610102573d90f35b3d90fdfea26474726f6e5822122019fba3a984dfef08920adc4d0e531dbd369df1dec237bfb02ce668f5d8e2704064736f6c63430008140033";
    static let mainnet_creationCodeStr = "0x60a06040908082526103e5803803809161001982856101d6565b833981019082818303126101d2576100308161020d565b91602091828101519060018060401b0382116101d2570181601f820112156101d25780519061005e8261022a565b9261006b875194856101d6565b8284528483830101116101d25783905f5b8381106101be5750505f9183010152823b1561017a5780516100b3575b50506080525161013c90816102a982396080518160180152f35b8351635c60da1b60e01b81529082826004816001600160a01b0388165afa918215610170575f9261012d575b50905f80838561011c9695519101845af4903d15610124573d6101018161022a565b9061010e885192836101d6565b81525f81943d92013e610245565b505f80610099565b60609250610245565b90918382813d8311610169575b61014481836101d6565b810103126101665750905f8061015d61011c959461020d565b939450506100df565b80fd5b503d61013a565b85513d5f823e3d90fd5b835162461bcd60e51b815260048101839052601b60248201527f626561636f6e2073686f756c64206265206120636f6e747261637400000000006044820152606490fd5b81810183015185820184015285920161007c565b5f80fd5b601f909101601f19168101906001600160401b038211908210176101f957604052565b634e487b7160e01b5f52604160045260245ffd5b516001600160a81b03811681036101d2576001600160a01b031690565b6001600160401b0381116101f957601f01601f191660200190565b9061026c575080511561025a57805190602001fd5b604051630a12f52160e11b8152600490fd5b8151158061029f575b61027d575090565b604051639996b31560e01b81526001600160a01b039091166004820152602490fd5b50803b1561027556fe60806040819052635c60da1b60e01b81526020816004817f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03165afa9081156100ae575f91610056575b506100e8565b6020903d82116100a6575b601f8201601f1916810167ffffffffffffffff8111828210176100925761008c9350604052016100b9565b5f610050565b634e487b7160e01b84526041600452602484fd5b3d9150610061565b6040513d5f823e3d90fd5b602090607f1901126100e4576080516001600160a81b03811681036100e4576001600160a01b031690565b5f80fd5b5f808092368280378136915af43d82803e15610102573d90f35b3d90fdfea26474726f6e58221220309a2919b7a1b203f1a7a1c544a7d671bb94b0adf8a39e4c9b6eeb6d03939ffe64736f6c63430008140033"

    enum TronLinkGasfreeEnv {
        case nile
        case shasta
        case online
        
        var chainId: Int {
            switch self {
            case .nile:
                return Int(nile_chainId.drop0x,radix: 16) ?? 0
            case .shasta:
                return Int(shasta_chainId.drop0x,radix: 16) ?? 0
            case .online:
                return Int(mainnet_chainId.drop0x,radix: 16) ?? 0
            }
        }
        
        var verifyingContract: String {
            switch self {
            case .nile:
                return nile_verifyingContract
            case .shasta:
                return shasta_verifyingContract
            case .online:
                return mainnet_verifyingContract
            }
        }
        
        var beaconAddress: String {
            switch self {
            case .nile:
                return nile_beaconAddress
            case .shasta:
                return shasta_beaconAddress
            case .online:
                return mainnet_beaconAddress
            }
        }
        
        var creationCode: String {
            switch self {
            case .nile,.shasta:
                return test_creationCodeStr
            case .online:
                return mainnet_creationCodeStr
            }
        }
    }
}

class GasFreeCommon: NSObject {
    
    class func createSigner712Struct(chainId: String,
                                       verifyingContract: String,
                                       token: String,
                                       serviceProvider: String,
                                       user: String,
                                       receiver: String,
                                       value: String,
                                       maxFee: String,
                                       deadline: Int64,
                                       version: Int64,
                                       nonce: Int64) -> NSMutableDictionary? {

        let domain: [String: Any] = [
            "chainId": chainId,
            "name": "GasFreeController",
            "verifyingContract": verifyingContract,
            "version": "V1.0.0"
        ]
        
        let message: [String: Any] = [
            "token": token,
            "serviceProvider": serviceProvider,
            "user": user,
            "receiver": receiver,
            "value": value,
            "maxFee": maxFee,
            "deadline": deadline,
            "nonce": nonce,
            "version": version
        ]
        
        let mutableDictionary: NSMutableDictionary = [
            "domain": domain,
            "message": message,
            "primaryType": "PermitTransfer",
            "types": [
                "PermitTransfer": [
                    ["name": "token", "type": "address"],
                    ["name": "serviceProvider", "type": "address"],
                    ["name": "user", "type": "address"],
                    ["name": "receiver", "type": "address"],
                    ["name": "value", "type": "uint256"],
                    ["name": "maxFee", "type": "uint256"],
                    ["name": "deadline", "type": "uint256"],
                    ["name": "version", "type": "uint256"],
                    ["name": "nonce", "type": "uint256"]
                ],
                "EIP712Domain": [
                    ["name": "name", "type": "string"],
                    ["name": "version", "type": "string"],
                    ["name": "chainId", "type": "uint256"],
                    ["name": "verifyingContract", "type": "address"]
                ]
            ]
        ]
        
        return mutableDictionary
    }
    
    class func getCurrentEnv(chainId:String) -> TronLinkGasfreeConfig.TronLinkGasfreeEnv {
        if chainId == TronLinkGasfreeConfig.nile_chainId {
            return .nile
        }else if chainId == TronLinkGasfreeConfig.shasta_chainId {
            return .shasta
        }else {
            return .online
        }
    }
    
    class func getByte32(base58Data: Data?) -> Data {
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
    
    class func base58CheckDecodeRemove41(address: String) -> Data {
        guard let data = address.base58CheckData, data.count > 1 else {
            return Data()
        }
        let bytes = data[1..<data.count]
        return bytes
    }
    

    class func getAddressByte(byte32: Data) -> Data {
        var resultData = Data()
        if byte32.count > 12 {
            resultData.append(TronLinkGasfreeConfig.preHexUInt)
            let addressByte = byte32[12..<byte32.count]
            resultData.append(addressByte)
        }
        return resultData
    }
    
    class func getEthereumAdress(tronAddress: String) -> String {
        let address = tronAddress.convertTronAddressToBase58HexAddress()
        if address.hasPrefix("41") {
            return String(address.dropFirst(2)).add0x
        }
        return address
    }
    
}
