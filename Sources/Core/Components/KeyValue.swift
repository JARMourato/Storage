// Copyright © 2022 JARMourato All rights reserved.

import Combine
import Foundation

// MARK: - Property Wrapper

/// This property wrapper allows setting and retrieving values from a `KeyValueStore`.
@propertyWrapper
public final class KeyValue<Value>: Storage<KeyValueStore<Value>, Value> {
    override public var wrappedValue: Value {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    override public var projectedValue: AnyPublisher<Value, Never> {
        super.projectedValue
    }

    /// Creates a new `KeyValue` property wrapper for the given key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store.
    ///   - defaultValue: the value to be used when nothing is stored
    public init(container: KeyValueContainer, key: String, defaultValue: Value, encrypter: Encryptable? = nil) {
        let store = KeyValueStore<Value>(container: container, encrypter: encrypter, key: key)
        super.init(store: store, defaultValue: defaultValue)
    }
}

public extension KeyValue where Value: ExpressibleByNilLiteral {
    /// Creates a new User Defaults property wrapper for the given key.
    /// - Parameters:
    ///   - password: The password used to encrypt the value.
    ///   - key: The key to use with the user defaults store.
    convenience init(container: KeyValueContainer, key: String, encrypter: Encryptable? = nil) {
        self.init(container: container, key: key, defaultValue: nil, encrypter: encrypter)
    }
}

// MARK: - Store

/// This `Store` accesses a `Container` which allows storing values, with an optional password to encrypt the value.
public struct KeyValueStore<Value>: Store {
    private var container: KeyValueContainer
    private let encrypter: Encryptable?
    private let key: String

    public init(container: KeyValueContainer, encrypter: Encryptable? = nil, key: String) {
        self.container = container
        self.encrypter = encrypter
        self.key = key
    }

    public func store(value: Value) throws {
        try container.set(encryptIfNeeded(value: value), forKey: key)
    }

    public func getValue() throws -> Value? {
        guard
            let storedValue = try container.object(forKey: key),
            let value = try decryptValueIfNeeded(value: storedValue)
        else { return nil }

        return value as? Value
    }

    public func erase() throws {
        try container.removeObject(forKey: key)
    }

    // MARK: Encryption logic

    private func encryptIfNeeded(value: Any) throws -> Any {
        guard let encrypter else { return value }
        let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
        return try encrypter.encrypt(value: data)
    }

    private func decryptValueIfNeeded(value: Any) throws -> Any? {
        guard let encrypter else { return value } // The value is a non-encrypted value
        guard let data = value as? Data else { return nil } // Because encrypter is set the value should be encrypted and thus be Data
        let decrypted = try encrypter.decrypt(data: data)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decrypted)
    }
}
