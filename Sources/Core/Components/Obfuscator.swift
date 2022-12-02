// Copyright © 2022 JARMourato All rights reserved.

import CryptoKit
import Foundation

// MARK: - Obfuscator

/// A `Data` obfuscator that uses `ChaChaPoly` algorithm.
/// `ChaChaPoly` was chosen for being fast (up to 3 times faster than AES), and for featuring low power consumption, ideal for mobile environments.
public class Obfuscator: Encryptable {
    private let password: String

    public init(password: String) {
        self.password = password
    }

    public func encrypt(value: Data) throws -> Data {
        let key = createKey(from: password)
        let encryptedData = try ChaChaPoly.seal(value, using: key)
        return encryptedData.combined
    }

    public func decrypt(data: Data) throws -> Data {
        let key = createKey(from: password)
        let box = try ChaChaPoly.SealedBox(combined: data)
        return try ChaChaPoly.open(box, using: key)
    }

    // MARK: Key handling

    private func createKey(from password: String) -> SymmetricKey {
        // Create a SHA256 hash from the provided password
        let hash = SHA256.hash(data: password.data(using: .utf8)!)
        // Convert the SHA256 to a string. This will be a 64 byte string
        let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
        // Convert to 32 bytes
        let subString = String(hashString.prefix(32))
        // Convert the substring to data
        let keyData = subString.data(using: .utf8)!
        // Create the key using `keyData` as the seed
        return SymmetricKey(data: keyData)
    }
}
