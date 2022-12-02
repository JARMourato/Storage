// Copyright © 2022 JARMourato All rights reserved.

@testable import Storage
import XCTest

final class KeyValueStorageTests: XCTestCase {
    private var sut: Test!

    // MARK: Nested Types

    class Test {
        @KeyValue(container: MockKeyValueContainer(), key: "integer", defaultValue: 0) var nonOptionalInteger: Int
        @KeyValue(container: MockKeyValueContainer(), key: "optional_integer") var optionalInteger: Int?
    }

    class MockKeyValueContainer: KeyValueContainer {
        var map: [String: Any] = [:]

        func set(_ value: Any?, forKey defaultName: String) {
            map[defaultName] = value
        }

        func object(forKey defaultName: String) -> Any? {
            map[defaultName]
        }

        func removeObject(forKey key: String) throws {
            map[key] = nil
        }
    }

    override func setUp() {
        super.setUp()
        sut = Test()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_setAndGet_shouldReturnTheSameValuesUsingKeyValueWrapper() {
        // Given
        XCTAssertEqual(sut.nonOptionalInteger, 0)
        XCTAssertNil(sut.optionalInteger)
        // When
        sut.nonOptionalInteger = 1
        sut.optionalInteger = 1
        // Then
        XCTAssertEqual(sut.nonOptionalInteger, 1)
        XCTAssertEqual(sut.optionalInteger, 1)
    }

    func test_defaultsPublisher_shouldUpdateValueOnSet() {
        // Given
        let newValue = 2
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = sut.$nonOptionalInteger.sink { value in
            XCTAssertEqual(value, newValue)
            expectation.fulfill()
        }
        // When
        sut.nonOptionalInteger = newValue
        // Then
        XCTAssertEqual(sut.nonOptionalInteger, newValue)
        waitForExpectations(timeout: 5, handler: nil)
        cancellable.cancel()
    }

    func test_erase_keyValue_shouldMakeWrapperReturnNilOrDefaultValues() throws {
        // Given
        let testNonOptional = KeyValue(container: MockKeyValueContainer(), key: "integer", defaultValue: 10)
        let testOptional = KeyValue<Int?>(container: MockKeyValueContainer(), key: "optional_integer")
        XCTAssertEqual(testNonOptional.wrappedValue, 10)
        XCTAssertNil(testOptional.wrappedValue)
        // When
        testNonOptional.wrappedValue = 1
        XCTAssertEqual(testNonOptional.wrappedValue, 1)
        testOptional.wrappedValue = 1
        XCTAssertEqual(testOptional.wrappedValue, 1)
        // Then
        try testNonOptional.erase()
        try testOptional.erase()
        XCTAssertEqual(testNonOptional.wrappedValue, 10)
        XCTAssertNil(testOptional.wrappedValue)
    }
}
