import Foundation
import TLCore
import CryptoSwift

public enum GasFreeGeneratorError: Error, LocalizedError {
    case invalidToken
    case invalidUser
    case invalidReceiver
    case invalidServiceProvider
    case invalidVerifyingContract
    case invalidTypedData
    case jsonDecodeError(Error)
    case jsonConversionError(Error)
    case invalidJSONString

    public var localizedDescription: String {
        switch self {
        case .invalidToken:
            return "Invalid message, token should be a valid Tron address"
        case .invalidUser:
            return "Invalid message, user should be a valid Tron address"
        case .invalidReceiver:
            return "Invalid message, receiver should be a valid Tron address"
        case .invalidServiceProvider:
            return "Invalid message, serviceProvider should be a valid Tron address"
        case .invalidVerifyingContract:
            return "Invalid domain, verifyingContract should be a valid Tron address"
        case .invalidTypedData:
            return "Expected the GasFreeController V1.0.0 PermitTransfer schema"
        case .jsonDecodeError(let error):
            return "Error decoding or encoding typed data: \(error)"
        case .jsonConversionError(let error):
            return "Error converting data to JSON: \(error)"
        case .invalidJSONString:
            return "Invalid JSON string"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}

/// Computes GasFree addresses and unsigned PermitTransfer hashes without wallet state.
public class GasFreeGenerator: NSObject {
    @objc public static let shareManager = GasFreeGenerator()

    // MARK: - GasFree message hash

    /// Returns a 0x-prefixed hash. Addresses may be Base58Check or supported hex forms.
    /// The caller remains responsible for chain/contract selection and transaction policy.
    public func permitTransferMessageHash(chainId: String,
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
        let dictionary = GasFreeCommon.createSigner712Struct(
            chainId: chainId, verifyingContract: verifyingContract,
            token: token, serviceProvider: serviceProvider, user: user,
            receiver: receiver, value: value, maxFee: maxFee,
            deadline: deadline, version: version, nonce: nonce
        )
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        } catch {
            throw GasFreeGeneratorError.jsonConversionError(error)
        }
        return try permitTransferMessageHash(data: data)
    }

    /// Hashes the standard GasFreeController V1.0.0 PermitTransfer payload.
    /// Use decimal strings for uint256 values that cannot be represented exactly as JSON numbers.
    public func permitTransferMessageHash(gasfreeJSONString: String) throws -> String {
        guard let data = gasfreeJSONString.data(using: .utf8) else {
            throw GasFreeGeneratorError.invalidJSONString
        }
        return try permitTransferMessageHash(data: data)
    }

    private func permitTransferMessageHash(data: Data) throws -> String {
        let typed: EIP712TypedData
        do {
            typed = try JSONDecoder().decode(EIP712TypedData.self, from: data)
        } catch {
            throw GasFreeGeneratorError.jsonDecodeError(error)
        }
        guard GasFreeCommon.hasStandardSchema(typed) else {
            throw GasFreeGeneratorError.invalidTypedData
        }
        guard let token = typed.message["token"]?.stringValue,
              GasFreeCommon.isValidTypedAddress(token) else {
            throw GasFreeGeneratorError.invalidToken
        }
        guard let user = typed.message["user"]?.stringValue,
              GasFreeCommon.isValidTypedAddress(user) else {
            throw GasFreeGeneratorError.invalidUser
        }
        guard let receiver = typed.message["receiver"]?.stringValue,
              GasFreeCommon.isValidTypedAddress(receiver) else {
            throw GasFreeGeneratorError.invalidReceiver
        }
        guard let provider = typed.message["serviceProvider"]?.stringValue,
              GasFreeCommon.isValidTypedAddress(provider) else {
            throw GasFreeGeneratorError.invalidServiceProvider
        }
        guard let contract = typed.domain["verifyingContract"]?.stringValue,
              GasFreeCommon.isValidTypedAddress(contract) else {
            throw GasFreeGeneratorError.invalidVerifyingContract
        }
        do {
            return try typed.signHash().hexEncoded
        } catch {
            // Preserve ABI/schema failures; never hash a partially encoded message.
            throw GasFreeGeneratorError.jsonDecodeError(error)
        }
    }

    // MARK: - GasFree address

    /// Supports Mainnet, Nile and Shasta chain IDs in decimal or hexadecimal form.
    /// Returns an empty string for an unsupported chain or invalid input.
    public func generateGasFreeAddress(chainId: String, userAddress: String) -> String {
        guard let env = GasFreeCommon.getCurrentEnv(chainId: chainId) else {
            return ""
        }
        return generateGasFreeAddress(
            userAddress: userAddress, gasFreeFactoryAddress: env.verifyingContract,
            beaconAddress: env.beaconAddress, creationCodeStr: env.creationCode
        )
    }

    /// Computes an address for an explicit deployment. All three addresses must be
    /// TRON Base58Check addresses. Returns an empty string on invalid input or ABI failure.
    public func generateGasFreeAddress(userAddress: String,
                                      gasFreeFactoryAddress: String,
                                      beaconAddress: String,
                                      creationCodeStr: String) -> String {
        guard let userData = GasFreeCommon.tronAddressData(userAddress),
              let factoryData = GasFreeCommon.tronAddressData(gasFreeFactoryAddress),
              let beaconData = GasFreeCommon.tronAddressData(beaconAddress),
              let creationCode = creationCodeStr.hexDecodedData() else {
            return ""
        }

        let salt = GasFreeCommon.getByte32(base58Data: userData)
        let beacon = GasFreeCommon.getByte32(base58Data: beaconData)
        do {
            // abi.encodeCall(initialize, (user))
            let initialize = Function(name: "initialize", parameters: [.address])
            let callEncoder = ABIEncoder()
            try callEncoder.encode(function: initialize, arguments: [TLCore.Address(data: salt)])

            // Proxy constructor arguments: abi.encode(beacon, initializeCall).
            let constructorEncoder = ABIEncoder()
            try constructorEncoder.encode(tuple: [
                try ABIValue(TLCore.Address(data: beacon), type: .address),
                try ABIValue(callEncoder.data, type: .dynamicBytes)
            ])
            let bytecodeHash = (creationCode + constructorEncoder.data).sha3(.keccak256)

            // TRON CREATE2: keccak256(0x41 || factory20 || salt32 || bytecodeHash).
            var preimage = Data([GasfreeConfig.preHexUInt])
            preimage.append(contentsOf: factoryData.dropFirst())
            preimage.append(salt)
            preimage.append(bytecodeHash)
            let addressData = GasFreeCommon.getAddressByte(byte32: preimage.sha3(.keccak256))
            return String(base58CheckEncoding: addressData)
        } catch {
            return ""
        }
    }
}
