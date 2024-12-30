import XCTest
@testable import gasfree_sdk_swift
import TLCore
import TronKeystore

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGasFree712StructHash() {
        let gasfreeJSON = """
        {
          "domain": {
            "chainId": 3448148188,
            "name": "GasFreeController",
            "verifyingContract": "TNtzqaE9p23tzpN1SHavUCCuzSwrzbHEHE",
            "version": "V1.0.0"
          },
          "message": {
            "deadline": 1731066521,
            "maxFee": 1000000,
            "nonce": 0,
            "receiver": "TQ6qStrS2ZJ96gieZJC8AurTxwqJETmjfp",
            "serviceProvider": "TQ6qStrS2ZJ96gieZJC8AurTxwqJETmjfp",
            "token": "TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf",
            "user": "TKtWbdzEq5ss9vTS9kwRhBp5mXmBfBns3E",
            "value": 1000000,
            "version":1
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
        do {
            let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: gasfreeJSON)
            XCTAssertEqual(signHash, "0x18cc1af5a367707a4b514cb37c5f9b5be568c5761d6caed614c98b2e4943b210")
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testGasFreeMessageParam() {
        
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
        
        do {
            let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(chainId: chainId, verifyingContract: verifyingContract, token: token, serviceProvider: serviceProvider, user: user, receiver: receiver, value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce)
            XCTAssertEqual(signHash, "0x18cc1af5a367707a4b514cb37c5f9b5be568c5761d6caed614c98b2e4943b210")
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testGenerateGasFreeAddress() {
        let gasfreeAddress = GasFreeGenerator.shareManager.generateGasFreeAddress(chainId: TronLinkGasfreeConfig.nile_chainId, userAddress: "TLthCsi7GvwrrDVUws55sPiiTtMoMvmZ4Y")
        XCTAssertEqual(gasfreeAddress,"TSBfKBxikmHREViNSZA1ez9Cc9BhyzMUuk")
    }
    
}

