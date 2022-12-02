// Copyright © 2022 JARMourato All rights reserved.

import Combine
import Foundation
import Storage
import Valet

// MARK: - Keychain Wrapper

public typealias Keychain = KeyValue<String?>

// MARK: - Keychain Containers

public extension KeyValue where Value == String? {
    /// Creates a Keychain Wrapper
    /// - Parameters:
    ///   - kind: The type of keychain to use
    ///   - key: the key to retrieve the value stored in the keychain
    convenience init(_ kind: KeychainKind, key: String) {
        self.init(container: kind.createContainer(), key: key, defaultValue: nil)
    }
}

/// The entrypoint to support different types of keychain
public enum KeychainKind {
    case simple(identifier: String)

    func createContainer() -> KeyValueContainer {
        let valet: Valet

        switch self {
        case let .simple(identifier):
            valet = Valet.valet(with: Identifier(nonEmpty: identifier)!, accessibility: .whenUnlocked)
        }

        return KeychainContainer(valet: valet)
    }

    // MARK: Nested Types

    struct KeychainContainer: KeyValueContainer {
        let valet: Valet

        func set(_ value: Any?, forKey defaultName: String) throws {
            // Value can only be a string because `Keychain` is a typealias to `KeyValue<String?>`
            if let stringValue = value as? String {
                try valet.setString(stringValue, forKey: defaultName)
            } else {
                try removeObject(forKey: defaultName)
            }
        }

        func object(forKey defaultName: String) throws -> Any? {
            try valet.string(forKey: defaultName)
        }

        func removeObject(forKey key: String) throws {
            try valet.removeObject(forKey: key)
        }
    }
}
