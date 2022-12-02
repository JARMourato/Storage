// Copyright © 2022 JARMourato All rights reserved.

import Combine
import Foundation
import Storage

// MARK: - Property Wrapper

/// This property wrapper allows setting and retrieving values from a password-encrypted equivalent `UserDefaults`.
@propertyWrapper
public final class Defaults<Value>: Storage<KeyValueStore<Value>, Value> {
    override public var wrappedValue: Value {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }

    override public var projectedValue: AnyPublisher<Value, Never> {
        super.projectedValue
    }

    /// Creates a `UserDefaults` property wrapper for the given key, optionally password-encrypted.
    /// - Parameters:
    ///   - container: Any type that conforms to `KeyValueContainer` can be passed, defaults to `UserDefaults.standard`
    ///   - password: An optional password used to encrypt the value.
    ///   - key: The key to use with the user defaults store.
    ///   - defaultValue: the value to be used when nothing is stored.
    public init(container: KeyValueContainer = UserDefaults.standard, key: String, defaultValue: Value, password: String? = nil) {
        let encrypter = password.map { Obfuscator(password: $0) }
        let store = KeyValueStore<Value>(container: container, encrypter: encrypter, key: key)
        super.init(store: store, defaultValue: defaultValue)
    }
}

public extension Defaults where Value: ExpressibleByNilLiteral {
    /// Creates a new User Defaults property wrapper for the given key.
    /// - Parameters:
    ///   - password: The password used to encrypt the value.
    ///   - key: The key to use with the user defaults store.
    convenience init(container: KeyValueContainer = UserDefaults.standard, key: String, password: String? = nil) {
        self.init(container: container, key: key, defaultValue: nil, password: password)
    }
}

// MARK: - UserDefaults conformance to KeyValueContainer

extension UserDefaults: KeyValueContainer {}
