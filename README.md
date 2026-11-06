# gasfree-sdk

gasfree-sdk is a toolkit developed based on the GasFree API specification,
It facilitates the integration of the non-gas TRC20 token transfer service for the iOS platform.

Originally developed by TronLink and hosted at https://github.com/TronLink/gasfree-sdk-swift.git, this SDK is now maintained and continuously updated by the gasfree.io developer community.

For more information, visit [gasfree.io](https://gasfree.io).

Key Features:
- Generate GasFree Addresses from User Addresses
- Generate GasFree Transfer Message Hash

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 15.1+ (required by `tronlink-iOS-core 2.0.0`)
- Swift 4.2

## Compatibility

The SDK uses the consolidated `TLCore` module from `tronlink-iOS-core 2.0.0`.
After updating an existing checkout, run `pod install` in `Example` to regenerate
the CocoaPods integration before opening the example workspace.

The existing `GasFreeGenerator.shareManager` methods remain available through
`import gasfree_sdk`. Address generation returns an empty string on failure;
hash generation throws `GasFreeGeneratorError`.

- Address generation accepts Base58Check TRON addresses. The chain ID overload
  recognizes Mainnet, Nile and Shasta in decimal or hexadecimal (`0x`/`0X`) form.
  Unknown chain IDs return an empty string instead of selecting Mainnet. For a
  custom deployment, use the overload with explicit factory, beacon and creation code.
- Both hash overloads accept Base58Check addresses and their equivalent 20-byte
  hex, `0x` + 20-byte hex, `41` + 20-byte hex, or `0x41`/`0X41` + 20-byte hex forms.
- The JSON hash overload requires the standard `PermitTransfer` field names,
  types and order, with `EIP712Domain`, domain name `GasFreeController`, and domain
  version `V1.0.0`. Missing or extra domain/message fields, malformed values and
  out-of-range numbers are rejected. Duplicate object keys (including escaped
  equivalents) are rejected at every nesting level before typed-data decoding.
  JSON nesting is limited to 64 container levels.
  It is not a general-purpose EIP-712 hashing API.
- Use strings for large `uint256` values. The parameter overload keeps its `Int64`
  arguments for deadline, version and nonce; the JSON overload also accepts those
  values as decimal or hexadecimal strings. Unquoted JSON numbers must be unsigned
  decimal integer literals: fractions, negative numbers and exponent notation
  (including `1.0` and `1e3`) are rejected before numeric decoding.
- In both hash overloads, unsigned integer strings must contain ASCII decimal
  digits, or a `0x`/`0X` prefix followed by hexadecimal digits. Empty strings,
  a prefix without digits, signs and whitespace are rejected. Zero (`"0"`,
  `"0x0"`, `"0X0"`) and leading zeros remain valid numeric representations within
  the input limit: at most 78 decimal digits or 64 hexadecimal digits, counting
  leading zeros and excluding the hex prefix. The uint256 range is still checked.
  Address-generation chain IDs are also length-bounded before network selection
  (at most 78 input bytes, and at most 64 hex digits after trimming).
  Transaction-specific restrictions still belong to the caller.

Hash generation is deterministic and does not access the network or a wallet.
The caller must validate the selected chain and contract, token, service provider,
fees, message version, nonce and deadline before signing. The SDK does not hold
private keys, sign transactions, or enforce the App's current-wallet/service policies.

## Demo

- [testGasFreeMessageParam](./Example/Tests/Tests.swift)
- [testGasFree712StructHash](./Example/Tests/Tests.swift)
- [testGenerateGasFreeAddress](./Example/Tests/Tests.swift)

## Function 
import gasfree sdk 
```
    import gasfree_sdk
```
### generateGasFreeAddress

use generateGasFreeAddress with userAddress and general chainId (et. GasfreeConfig.nile_chainId 0xcd8690dc)
```
    let gasfreeAddress = GasFreeGenerator.shareManager.generateGasFreeAddress(chainId: GasfreeConfig.nile_chainId, userAddress: userAddress)
```
gasFreeAddress is your gasFree Address

or more param
use userAddress, gasFreeFactoryAddress,beaconAddress and creationCodeStr
```
    let gasfreeAddress = GasFreeGenerator.shareManager.generateGasFreeAddress(userAddress: userAddress, gasFreeFactoryAddress: gasFreeFactoryAddress, beaconAddress: beaconAddress, creationCodeStr: creationCodeStr)
```

### permitTransferMessageHash

with those params:
```
    let chainId: String 
    let verifyingContract: String 
    let token: String 
    let serviceProvider: String 
    let user: String 
    let receiver: String  
    let value: String  
    let maxFee: String  
    let deadline: Int64 
    let version: Int64 
    let nonce: Int64 
```
used permitTransferMessageHash function
```
    let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(chainId: chainId, verifyingContract: verifyingContract, token: token, serviceProvider: serviceProvider, user: user, receiver: receiver, value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce)
```
You will get the GasFree Transfer Message Hash.
Or hash an existing GasFree JSON payload:

```swift
let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: eipJson)
```

and more, you should sign the hash for real transaction.

## License
This project is licensed under the Apache License Version 2.0 - see the [LICENSE](LICENSE) file for details


