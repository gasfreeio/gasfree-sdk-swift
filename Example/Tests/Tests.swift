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
            "chainId": "728126428",
            "name": "GasFreeController",
            "verifyingContract": "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U",
            "version": "V1.0.0"
          },
          "message": {
            "deadline": 1740641152,
            "maxFee": "20000000",
            "nonce": 1,
            "receiver": "TSPrmJetAMo6S6RxMd4tswzeRCFVegBNig",
            "serviceProvider": "TLntW9Z59LYY5KEi9cmwk3PKjQga828ird",
            "token": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
            "user": "TFDP1vFeSYPT6FUznL7zUjhg5X7p2AA8vw",
            "value": "20000000",
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
            XCTAssertEqual(signHash, "0x4e0e1444d20768c286b9de66064e4e7311b5160871c8c0292ffeac9a16265622")
        }catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testGasFreeMessageParam() {
        
        let chainId: String = "728126428"
        let verifyingContract: String = "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U"
        let token: String = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
        let serviceProvider: String = "TLntW9Z59LYY5KEi9cmwk3PKjQga828ird"
        let user: String = "TFDP1vFeSYPT6FUznL7zUjhg5X7p2AA8vw"
        let receiver: String  = "TSPrmJetAMo6S6RxMd4tswzeRCFVegBNig"
        let value: String  = "20000000"
        let maxFee: String  = "20000000"
        let deadline: Int64 = 1740641152
        let version: Int64 = 1
        let nonce: Int64 = 1
        
        do {
            let signHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(chainId: chainId, verifyingContract: verifyingContract, token: token, serviceProvider: serviceProvider, user: user, receiver: receiver, value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce)
            XCTAssertEqual(signHash, "0x4e0e1444d20768c286b9de66064e4e7311b5160871c8c0292ffeac9a16265622")
        }catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testGenerateGasFreeAddress() {
        let gasfreeAddress = GasFreeGenerator.shareManager.generateGasFreeAddress(chainId: GasfreeConfig.mainnet_chainId, userAddress: "TLFXfejEMgivFDR2x8qBpukMXd56spmFhz")
        XCTAssertEqual(gasfreeAddress,"TYKTmMyTeAFrfdRTpYHjnAtFEJtMMotJJe")
    }
    
}

