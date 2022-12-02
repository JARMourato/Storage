// Copyright © 2022 JARMourato All rights reserved.

import Foundation

// MARK: - Protocols

/// Defines a contract to encrypt/decrypt data
public protocol Encryptable {
    func encrypt(value: Data) throws -> Data
    func decrypt(data: Data) throws -> Data
}

/// Defines the contract to be used by any sort of Key-Value container/store
public protocol KeyValueContainer {
    func set(_ value: Any?, forKey defaultName: String) throws
    func object(forKey defaultName: String) throws -> Any?
    func removeObject(forKey key: String) throws
}
