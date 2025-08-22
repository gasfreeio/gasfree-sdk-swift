# gasfree-sdk

gasfree-sdk is a toolkit developed based on the GasFree API specification,
It facilitates the integration of the non-gas TRC20 token transfer service for the iOS platform.

This SDK is maintained by the gasfree.io developer community.For more information, visit [gasfree.io](https://gasfree.io).

Key Features:
- Generate GasFree Addresses from User Addresses
- Generate GasFree Transfer Message Hash

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 10.0+
- Swift 4.2

## How to use

gasfree-sdk is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'gasfree-sdk'
```

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
or you just use the permitTransferMessageHash(eipJson) function.

and more, you should sign the hash for real transaction.

## License
This project is licensed under the Apache License Version 2.0 - see the [LICENSE](LICENSE) file for details


