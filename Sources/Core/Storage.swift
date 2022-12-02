// Copyright © 2022 JARMourato All rights reserved.

import Combine
import Foundation

/// Parent class that handles common operations for any kind of `Storage`
open class Storage<S, Value> where S: Store, S.Value == Value {
    private let store: S
    private let defaultValue: Value
    private let publisher = PassthroughSubject<Value, Never>()

    /// - Note: Unfortunately, property wrappers don't allow throwing as of Swift 5.7 unless it is a readonly property, so this will work on best-effort basis.
    open var wrappedValue: Value {
        get { (try? store.getValue()) ?? defaultValue }
        set { try? store.store(value: newValue); publisher.send(newValue) }
    }

    open var projectedValue: AnyPublisher<Value, Never> {
        publisher.eraseToAnyPublisher()
    }

    public func erase() throws {
        try store.erase()
    }

    public init(store: S, defaultValue: Value) {
        self.store = store
        self.defaultValue = defaultValue
    }
}
