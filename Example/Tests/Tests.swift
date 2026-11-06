import XCTest
import Foundation
import gasfree_sdk

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
    
    private var gasfreeJSON: String {
        return """
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
    }

    func testGasFree712StructHash() {
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

    func testAddressGenerationRecognizesDecimalAndHexNetworks() {
        let generator = GasFreeGenerator.shareManager
        let user = "TLFXfejEMgivFDR2x8qBpukMXd56spmFhz"
        let networks = [
            (GasfreeConfig.mainnet_chainId, "728126428"),
            (GasfreeConfig.nile_chainId, "3448148188"),
            (GasfreeConfig.shasta_chainId, "2494104990")
        ]
        var addresses = Set<String>()
        for (hex, decimal) in networks {
            let address = generator.generateGasFreeAddress(chainId: hex, userAddress: user)
            XCTAssertFalse(address.isEmpty)
            XCTAssertEqual(generator.generateGasFreeAddress(chainId: decimal, userAddress: user), address)
            XCTAssertEqual(generator.generateGasFreeAddress(chainId: hex.uppercased(), userAddress: user), address)
            addresses.insert(address)
        }
        XCTAssertEqual(addresses.count, 3)
        for chain in ["", "0x", "1", "-1", "unknown", "0x2b6653dd"] {
            XCTAssertEqual(generator.generateGasFreeAddress(chainId: chain, userAddress: user), "")
        }
    }

    func testAddressGenerationRejectsInvalidDeploymentInputs() {
        let generator = GasFreeGenerator.shareManager
        let user = "TLFXfejEMgivFDR2x8qBpukMXd56spmFhz"
        let factory = "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U"
        let beacon = "TSP9UW6FQhT76XD2jWA6ipGMx3yGbjDffP"
        for invalid in ["", "invalid", String(repeating: "T", count: 1000), String(user.dropLast()) + "1"] {
            XCTAssertEqual(generator.generateGasFreeAddress(chainId: GasfreeConfig.mainnet_chainId, userAddress: invalid), "")
            XCTAssertEqual(generator.generateGasFreeAddress(userAddress: user, gasFreeFactoryAddress: invalid, beaconAddress: beacon, creationCodeStr: "00"), "")
            XCTAssertEqual(generator.generateGasFreeAddress(userAddress: user, gasFreeFactoryAddress: factory, beaconAddress: invalid, creationCodeStr: "00"), "")
        }
        for code in ["", "0x", "0", "0x0", "0xgg", "00zz"] {
            XCTAssertEqual(generator.generateGasFreeAddress(userAddress: user, gasFreeFactoryAddress: factory, beaconAddress: beacon, creationCodeStr: code), "")
        }
    }

    func testHashAcceptsEquivalentAddressRepresentations() throws {
        // This Base58/hex pair is also a maintained main-app test vector.
        let hex = "8840e6c55b9ada326d211d818c34a994aeced808"
        let forms = ["TNPeeaaFB7K9cmo4uQpcU32zGK8G1NYqeL", hex, "0x" + hex, "41" + hex, "0x41" + hex, "0X41" + hex]
        var expectedHash: String?
        for address in forms {
            var payload = try samplePayload()
            var message = try XCTUnwrap(payload["message"] as? [String: Any])
            var domain = try XCTUnwrap(payload["domain"] as? [String: Any])
            for field in ["token", "user", "receiver", "serviceProvider"] {
                message[field] = address
            }
            domain["verifyingContract"] = address
            payload["message"] = message
            payload["domain"] = domain
            let result = try hash(payload)
            if let expected = expectedHash {
                XCTAssertEqual(result, expected)
            } else {
                expectedHash = result
            }
            let parameterHash = try GasFreeGenerator.shareManager.permitTransferMessageHash(
                chainId: "0x2b6653dc", verifyingContract: address,
                token: address, serviceProvider: address, user: address, receiver: address,
                value: "20000000", maxFee: "20000000", deadline: 1740641152, version: 1, nonce: 1
            )
            XCTAssertEqual(parameterHash, result)
        }
    }

    func testCustomDeploymentAcceptsPrefixedCreationCode() {
        let generator = GasFreeGenerator.shareManager
        func address(_ code: String) -> String {
            return generator.generateGasFreeAddress(
                userAddress: "TLFXfejEMgivFDR2x8qBpukMXd56spmFhz",
                gasFreeFactoryAddress: "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U",
                beaconAddress: "TSP9UW6FQhT76XD2jWA6ipGMx3yGbjDffP",
                creationCodeStr: code
            )
        }
        let expected = address("60006000")
        XCTAssertFalse(expected.isEmpty)
        XCTAssertEqual(address("0x60006000"), expected)
        XCTAssertEqual(address("0X60006000"), expected)
        XCTAssertNotEqual(address("60006001"), expected)
    }

    func testHashRejectsMissingAndExtraFields() throws {
        let original = try samplePayload()
        for section in ["domain", "message"] {
            let fields = try XCTUnwrap(original[section] as? [String: Any])
            for name in fields.keys {
                var payload = original
                var incomplete = fields
                incomplete.removeValue(forKey: name)
                payload[section] = incomplete
                XCTAssertThrowsError(try hash(payload), "Missing \(section).\(name)")
            }
            var payload = original
            var extra = fields
            extra["unexpected"] = "value"
            payload[section] = extra
            XCTAssertThrowsError(try hash(payload), "Extra \(section) field")
        }
    }

    func testHashRejectsNonstandardSchema() throws {
        var payload = try samplePayload()
        payload["primaryType"] = "OtherTransfer"
        XCTAssertThrowsError(try hash(payload))

        for (field, value) in [("name", "OtherController"), ("version", "V2.0.0")] {
            payload = try samplePayload()
            var domain = try XCTUnwrap(payload["domain"] as? [String: Any])
            domain[field] = value
            payload["domain"] = domain
            XCTAssertThrowsError(try hash(payload))
        }

        payload = try samplePayload()
        var types = try XCTUnwrap(payload["types"] as? [String: [[String: String]]])
        var fields = try XCTUnwrap(types["PermitTransfer"])
        fields.swapAt(0, 1)
        types["PermitTransfer"] = fields
        payload["types"] = types
        XCTAssertThrowsError(try hash(payload), "Changing field order changes the signed type")

        payload = try samplePayload()
        types = try XCTUnwrap(payload["types"] as? [String: [[String: String]]])
        let domainFields = types.removeValue(forKey: "EIP712Domain")
        types["OtherDomain"] = domainFields
        payload["types"] = types
        XCTAssertThrowsError(try hash(payload))
    }

    func testHashRejectsInvalidUnsignedValues() throws {
        let invalidValues: [Any] = [
            -1, "-1", 1.5, "1.5", 1e100, true, NSNull(),
            "0x1" + String(repeating: "0", count: 64)
        ]
        for field in ["value", "maxFee", "deadline", "version", "nonce"] {
            for value in invalidValues {
                var payload = try samplePayload()
                var message = try XCTUnwrap(payload["message"] as? [String: Any])
                message[field] = value
                payload["message"] = message
                XCTAssertThrowsError(try hash(payload), "Invalid \(field): \(value)")
            }
        }
    }

    func testRawJSONRejectsDuplicateKeysAtEverySchemaLevel() throws {
        let payload = try samplePayload()
        let types = try XCTUnwrap(payload["types"] as? [String: Any])
        let fields = try XCTUnwrap(types["PermitTransfer"] as? [[String: String]])
        let fieldsData = try JSONSerialization.data(withJSONObject: fields, options: [])
        let fieldsJSON = try XCTUnwrap(String(data: fieldsData, encoding: .utf8))
        // Inject duplicates into the raw text, after any fixture serialization.
        let replacements = [
            ("\"primaryType\": \"PermitTransfer\"", "\"primaryType\": \"PermitTransfer\", \"primaryType\": \"PermitTransfer\""),
            ("\"domain\": {", "\"domain\": { \"chainId\": \"728126428\","),
            ("\"message\": {", "\"message\": { \"value\": \"20000000\","),
            ("\"types\": {", "\"types\": { \"PermitTransfer\": \(fieldsJSON),"),
            ("\"name\": \"token\"", "\"name\": \"token\", \"name\": \"token\""),
            ("\"message\": {", "\"message\": { \"\\u0076alue\": \"20000000\",")
        ]
        for (original, replacement) in replacements {
            let json = gasfreeJSON.replacingOccurrences(of: original, with: replacement)
            XCTAssertThrowsError(try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: json))
        }
    }

    func testRawJSONRejectsFractionalAndExponentTokens() {
        let fields = [
            ("\"chainId\": \"728126428\"", "\"chainId\""),
            ("\"value\": \"20000000\"", "\"value\""),
            ("\"maxFee\": \"20000000\"", "\"maxFee\""),
            ("\"deadline\": 1740641152", "\"deadline\""),
            ("\"version\":1", "\"version\""),
            ("\"nonce\": 1", "\"nonce\"")
        ]
        for (original, key) in fields {
            for token in ["1.0000000000000001", "9007199254740990.5", "-0.1e-400", "1.0", "1e3", "0e0"] {
                let json = gasfreeJSON.replacingOccurrences(of: original, with: "\(key): \(token)")
                XCTAssertThrowsError(try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: json), "\(key): \(token)")
            }
        }
    }

    func testRawJSONPreservesIntegerLiteralsAndEscapedKeys() throws {
        for integer in ["0", "20000000", "9007199254740991", "9223372036854775807"] {
            let json = gasfreeJSON.replacingOccurrences(of: "\"value\": \"20000000\"", with: "\"value\": \(integer)")
            XCTAssertEqual(try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: json),
                           try parameterHash(value: integer))
        }
        let escaped = gasfreeJSON.replacingOccurrences(of: "\"value\":", with: "\"\\u0076alue\":")
        XCTAssertEqual(try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: escaped),
                       try parameterHash())
    }

    func testUInt256StringLengthLimitsAndRange() throws {
        let maximum = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        let accepted = [
            (String(repeating: "0", count: 77) + "1", "1"),
            ("0X" + String(repeating: "0", count: 63) + "1", "1"),
            (maximum, "0x" + String(repeating: "f", count: 64))
        ]
        for (value, equivalent) in accepted {
            XCTAssertEqual(try parameterHash(value: value), try parameterHash(value: equivalent))
            XCTAssertEqual(try parameterHash(maxFee: value), try parameterHash(maxFee: equivalent))
            XCTAssertEqual(try parameterHash(chainId: value), try parameterHash(chainId: equivalent))
        }
        let rejected = [
            String(repeating: "0", count: 78) + "1", // 79 decimal digits, despite value == 1.
            "0x" + String(repeating: "0", count: 64) + "1", // 65 hex digits.
            String(repeating: "0", count: 100_000) + "1",
            "115792089237316195423570985008687907853269984665640564039457584007913129639936" // 78 digits, but overflows.
        ]
        let original = try samplePayload()
        for value in rejected {
            XCTAssertThrowsError(try parameterHash(chainId: value))
            XCTAssertThrowsError(try parameterHash(value: value))
            XCTAssertThrowsError(try parameterHash(maxFee: value))
            for (section, field) in [("domain", "chainId"), ("message", "value"), ("message", "maxFee"),
                                     ("message", "deadline"), ("message", "version"), ("message", "nonce")] {
                var payload = original
                var values = try XCTUnwrap(payload[section] as? [String: Any])
                values[field] = value
                payload[section] = values
                XCTAssertThrowsError(try hash(payload), "\(section).\(field)")
            }
        }
    }

    func testAddressGenerationBoundsChainIDBeforeParsing() {
        let generator = GasFreeGenerator.shareManager
        let user = "TLFXfejEMgivFDR2x8qBpukMXd56spmFhz"
        let expected = generator.generateGasFreeAddress(chainId: GasfreeConfig.mainnet_chainId, userAddress: user)
        let decimal = String(repeating: "0", count: 69) + "728126428"
        let hex = "0x" + String(repeating: "0", count: 56) + "2b6653dc"
        XCTAssertEqual(generator.generateGasFreeAddress(chainId: decimal, userAddress: user), expected)
        XCTAssertEqual(generator.generateGasFreeAddress(chainId: hex, userAddress: user), expected)
        for chain in ["0" + decimal, "0x0" + String(hex.dropFirst(2)),
                      String(repeating: "0", count: 100_000) + "728126428",
                      String(repeating: "9", count: 100_000),
                      String(repeating: " ", count: 100_000) + "728126428"] {
            XCTAssertEqual(generator.generateGasFreeAddress(chainId: chain, userAddress: user), "")
        }
    }

    func testParameterHashRejectsMalformedUnsignedStrings() {
        for value in malformedUnsignedStrings {
            XCTAssertThrowsError(try parameterHash(value: value), "Invalid value: \(value.debugDescription)")
            XCTAssertThrowsError(try parameterHash(maxFee: value), "Invalid maxFee: \(value.debugDescription)")
            XCTAssertThrowsError(try parameterHash(chainId: value), "Invalid chainId: \(value.debugDescription)")
        }
    }

    func testJSONHashRejectsMalformedUnsignedStrings() throws {
        let original = try samplePayload()
        let fields = [
            ("domain", "chainId"),
            ("message", "value"), ("message", "maxFee"),
            ("message", "deadline"), ("message", "version"), ("message", "nonce")
        ]
        for (section, field) in fields {
            for value in malformedUnsignedStrings {
                var payload = original
                var values = try XCTUnwrap(payload[section] as? [String: Any])
                values[field] = value
                payload[section] = values
                XCTAssertThrowsError(try hash(payload), "Invalid \(section).\(field): \(value.debugDescription)")
            }
        }
    }

    func testHashOverloadsPreserveZeroValues() throws {
        var payload = try samplePayload()
        var domain = try XCTUnwrap(payload["domain"] as? [String: Any])
        var message = try XCTUnwrap(payload["message"] as? [String: Any])
        let fields = ["value", "maxFee", "deadline", "version", "nonce"]
        domain["chainId"] = 0
        for field in fields {
            message[field] = 0
        }
        payload["domain"] = domain
        payload["message"] = message
        let numericZeroHash = try hash(payload)

        for zero in ["0", "00", "0x0", "0X0", "0x00", "0X00"] {
            domain["chainId"] = zero
            for field in fields {
                message[field] = zero
            }
            payload["domain"] = domain
            payload["message"] = message
            XCTAssertEqual(try hash(payload), numericZeroHash)
            XCTAssertEqual(try parameterHash(chainId: zero, value: zero, maxFee: zero,
                                             deadline: 0, version: 0, nonce: 0), numericZeroHash)
        }
    }

    func testHashOverloadsPreserveNormalAmounts() throws {
        let expectedHash = "0x4e0e1444d20768c286b9de66064e4e7311b5160871c8c0292ffeac9a16265622"
        for amount in ["20000000", "020000000", "0x1312d00", "0X1312D00"] {
            var payload = try samplePayload()
            var message = try XCTUnwrap(payload["message"] as? [String: Any])
            message["value"] = amount
            message["maxFee"] = amount
            payload["message"] = message
            XCTAssertEqual(try hash(payload), expectedHash)
            XCTAssertEqual(try parameterHash(value: amount, maxFee: amount), expectedHash)
        }
    }

    func testHashKeepsLargeIntegerStringsExact() throws {
        let maxUInt256 = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        var payload = try samplePayload()
        var message = try XCTUnwrap(payload["message"] as? [String: Any])
        message["value"] = maxUInt256
        message["nonce"] = "18446744073709551615"
        payload["message"] = message
        let decimalHash = try hash(payload)
        message["value"] = "0x" + String(repeating: "f", count: 64)
        message["nonce"] = "0xffffffffffffffff"
        payload["message"] = message
        XCTAssertEqual(try hash(payload), decimalHash)
        message["nonce"] = "18446744073709551614"
        payload["message"] = message
        XCTAssertNotEqual(try hash(payload), decimalHash)
    }

    func testInvalidAddressErrorsAreNotHiddenByJSONConversion() throws {
        var payload = try samplePayload()
        var message = try XCTUnwrap(payload["message"] as? [String: Any])
        message["token"] = "T" + String(repeating: "1", count: 1000)
        payload["message"] = message
        XCTAssertThrowsError(try hash(payload)) { error in
            guard let sdkError = error as? GasFreeGeneratorError else {
                return XCTFail("Expected an SDK error: \(error)")
            }
            switch sdkError {
            case .invalidToken:
                XCTAssertEqual(error.localizedDescription, sdkError.localizedDescription)
            default:
                XCTFail("Expected invalidToken, got \(sdkError)")
            }
        }
    }

    private var malformedUnsignedStrings: [String] {
        return [
            "", "0x", "0X", "+", "+0", "+20000000", "0x+1", "0X+1",
            "-0", "-1", "0x-1", " ", " 0", "0 ", "\t1", "1\n", "1 0", "0x 1",
            "1.0", "1e3", "0xgg", "20000000x", "０", "١",
            "1+000000000000000001"
        ]
    }

    private func parameterHash(chainId: String = "728126428",
                               value: String = "20000000",
                               maxFee: String = "20000000",
                               deadline: Int64 = 1740641152,
                               version: Int64 = 1,
                               nonce: Int64 = 1) throws -> String {
        return try GasFreeGenerator.shareManager.permitTransferMessageHash(
            chainId: chainId, verifyingContract: "TFFAMQLZybALaLb4uxHA9RBE7pxhUAjF3U",
            token: "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", serviceProvider: "TLntW9Z59LYY5KEi9cmwk3PKjQga828ird",
            user: "TFDP1vFeSYPT6FUznL7zUjhg5X7p2AA8vw", receiver: "TSPrmJetAMo6S6RxMd4tswzeRCFVegBNig",
            value: value, maxFee: maxFee, deadline: deadline, version: version, nonce: nonce
        )
    }

    private func samplePayload() throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(gasfreeJSON.utf8), options: [])
        return try XCTUnwrap(object as? [String: Any])
    }

    private func hash(_ payload: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: payload, options: [])
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        return try GasFreeGenerator.shareManager.permitTransferMessageHash(gasfreeJSONString: json)
    }
    
}

