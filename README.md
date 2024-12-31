# gasfree-sdk-swift

gasfree-sdk-swift is a comprehensive toolkit designed to streamline and simplify gasFree development by TronLink.
This SDK provides a collection of utility classes and methods to enhance the efficiency and ease of implementing gasFree transactions in iOS applications.

Key Features:
- Generate gasFree Addresses from User Addresses
- Generate gasFree EIP-712 Transfer Message Hash

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 10.0+
- Swift 4.2

## Installation

gasfree-sdk-swift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'gasfree-sdk-swift'
```

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
    let chainId: String = "3448148188"
    let verifyingContract: String = "TNtzqaE9p23tzpN1SHavUCCuzSwrzbHEHE"
    let token: String = "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf"
    let serviceProvider: String = "TQ6qStrS2ZJ96gieZJC8AurTxwqJETmjfp"
    let user: String = "TKtWbdzEq5ss9vTS9kwRhBp5mXmBfBns3E"
    let receiver: String  = "TQ6qStrS2ZJ96gieZJC8AurTxwqJETmjfp"
    let value: String  = "1000000"
    let maxFee: String  = "1000000"
    let deadline: Int64 = 1731066521
    let version: Int64 = 1
    let nonce: Int64 = 0
```
used permitTransferMessageHash function
```
    let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(chainId: chainId, verifyingContract: verifyingContract, token: token, serviceProvider: serviceProvider, user: user, receiver: receiver, value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce)
```
You will get the GasFree Transfer Message Hash.
or you just use the permitTransferMessageHash(eipJson) function.

and more, you should sign the hash for real transaction.


