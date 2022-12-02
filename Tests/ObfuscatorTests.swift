// Copyright © 2022 JARMourato All rights reserved.

import CryptoKit
@testable import Storage
import XCTest

final class ObfuscatorTests: XCTestCase {
    func test_encryptAndDecrypt_shouldOnlyWorkWithTheCorrectPassword() throws {
        let password = "password"
        let string = "This is the data we are encrypting"
        let data = string.data(using: .utf8)!
        let encrypter = Obfuscator(password: password)
        let fakeEncrypter = Obfuscator(password: "Not the password")
        let encryptedData = try encrypter.encrypt(value: data)

        let stringFromEncryptedData = String(data: encryptedData, encoding: .utf8)
        XCTAssertNil(stringFromEncryptedData)

        XCTAssertThrowsError(try fakeEncrypter.decrypt(data: encryptedData), "Should not be able to decrypt data with the wrong password") {
            // CryptoKitError does not conform to Equatable, hence XCTAssertEqual is not possible
            guard case CryptoKitError.authenticationFailure = $0 else {
                return XCTFail("Should throw CryptoKitError.authenticationFailure")
            }
        }

        XCTAssertThrowsError(try encrypter.decrypt(data: data), "Should not be able to decrypt data that was not encrypted to begin with") {
            // CryptoKitError does not conform to Equatable, hence XCTAssertEqual is not possible
            guard case CryptoKitError.authenticationFailure = $0 else {
                return XCTFail("Should throw CryptoKitError.authenticationFailure")
            }
        }

        let decryptedData = try encrypter.decrypt(data: encryptedData)
        let stringFromDecryptedData = String(data: decryptedData, encoding: .utf8)
        XCTAssertEqual(stringFromDecryptedData, string)
    }
}
