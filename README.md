# tronlink-gasfree-sdk-swift

tronlink-gasfree-sdk-swift is a toolkit developed by TronLink based on the GasFree API specification. It facilitates the integration of the non-gas TRC20 token transfer service for the iOS platform.

This SDK is provided by TronLink, while the definition & maintenance of the APIs are managed by the official GasFree project. For more information, visit [gasfree.io](https://gasfree.io).

Key Features:
- Generate GasFree Addresses from User Addresses
- Generate GasFree Transfer Message Hash

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 10.0+
- Swift 4.2

## Demo

- [testGasFreeMessageParam](./Example/Tests/Tests.swift)
- [testGasFree712StructHash](./Example/Tests/Tests.swift)
- [testGenerateGasFreeAddress](./Example/Tests/Tests.swift)

## Function 
import gasfree sdk 
```
    import gasfree_sdk_swift
```
### generateGasFreeAddress

use generateGasFreeAddress with userAddress and general chainId (et. TronLinkGasfreeConfig.nile_chainId 0xcd8690dc)
```
    let gasfreeAddress = GasFreeGenerator.shareManager.generateGasFreeAddress(chainId: TronLinkGasfreeConfig.nile_chainId, userAddress: userAddress)
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
or you just use the permitTransferMessageHash(eipJson) function.

and more, you should sign the hash for real transaction.

## Integrity Check
The package files will be signed using a GPG key pair, and the correctness of the signature will be verified using the following public key:
```
  pub: 7B910EA80207596075E6D7BA5D34F7A6550473BA
  uid: build_tronlink <build@tronlink.org>
```
## License
This project is licensed under the Apache License Version 2.0 - see the [LICENSE](LICENSE) file for details


