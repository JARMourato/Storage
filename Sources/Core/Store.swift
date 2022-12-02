// Copyright © 2022 JARMourato All rights reserved.

import Foundation

/// A protocol that defines a generic `ValueStore`, with its basic functionality of getting and setting a value.
public protocol Store {
    associatedtype Value

    /// Store the `Value`
    /// - Parameter value: the new value to be stored
    func store(value: Value) throws

    /// Get the stored `Value`
    func getValue() throws -> Value?

    /// Deletes the stored value
    func erase() throws
}
