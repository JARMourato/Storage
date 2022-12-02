// Copyright © 2022 JARMourato All rights reserved.

@testable import Storage
@testable import StoragePlus
import XCTest

final class DefaultsStorageTests: XCTestCase {
    private var sut: Test!
    static var mockedDefaults: MockUserDefaults = .init()

    // MARK: Nested Types

    struct Test {
        @Defaults(container: DefaultsStorageTests.mockedDefaults, key: "string") var string: String?
        @Defaults(container: DefaultsStorageTests.mockedDefaults, key: "non_optional_integer", defaultValue: 18) var optionalInteger: Int
        @Defaults(container: DefaultsStorageTests.mockedDefaults, key: "secret", password: "password") var secret: String?
    }

    class MockUserDefaults: KeyValueContainer {
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

        func clear() {
            map = [:]
        }
    }

    override func setUp() {
        super.setUp()
        sut = Test()
        DefaultsStorageTests.mockedDefaults.clear()
    }

    override func tearDown() {
        DefaultsStorageTests.mockedDefaults.clear()
        sut = nil
        super.tearDown()
    }

    func test_setAndGet_shouldReturnTheSameValuesUsingDefaultsWrapper() {
        // Given
        let userDefaults = DefaultsStorageTests.mockedDefaults
        // When
        userDefaults.set("value", forKey: "string")
        userDefaults.set(32, forKey: "non_optional_integer")
        // Then
        XCTAssertEqual(sut.string, userDefaults.object(forKey: "string") as? String)
        XCTAssertEqual(sut.optionalInteger, userDefaults.object(forKey: "non_optional_integer") as? Int)
    }

    func test_defaultsPublisher_shouldUpdateValueOnSet() {
        // Given
        let userDefaults = DefaultsStorageTests.mockedDefaults
        // When
        let value = "newValue"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = sut.$string.sink { newValue in
            XCTAssertEqual(value, newValue)
            expectation.fulfill()
        }
        sut.string = value
        // Then
        XCTAssertEqual(value, userDefaults.object(forKey: "string") as? String)
        XCTAssertEqual(sut.string, userDefaults.object(forKey: "string") as? String)
        waitForExpectations(timeout: 5, handler: nil)
        cancellable.cancel()
    }

    func test_readNonExistentValue_shouldReturnDefaultsFallBackDefaultValue() throws {
        // Given
        let userDefaults = DefaultsStorageTests.mockedDefaults
        // When
        try userDefaults.removeObject(forKey: "non_optional_integer")
        // Then
        XCTAssertNil(userDefaults.object(forKey: "non_optional_integer"))
        XCTAssertNotEqual(sut.optionalInteger, userDefaults.object(forKey: "non_optional_integer") as? Int)
        XCTAssertEqual(sut.optionalInteger, 18)
    }

    func test_readUnencryptedValue_shouldReturnNilByDefaults() {
        // Given
        let userDefaults = DefaultsStorageTests.mockedDefaults
        // When
        userDefaults.set("12345678", forKey: "secret")
        // Then
        XCTAssertNil(sut.secret, "The value 12345678 can't be decrypted by the given password, so it must be nil.")
    }

    func test_setEncryptedValue_shouldOnlyBeReadableByDefaults() {
        // Given
        let userDefaults = DefaultsStorageTests.mockedDefaults
        let secret = "plain_text"
        // When
        sut.secret = secret
        // Then
        XCTAssertNil(userDefaults.object(forKey: "secret") as? String, "The encrypted value isn't stored as a String, but as Data, so its String value must be nil.")
        let rawData = userDefaults.object(forKey: "secret") as? Data
        XCTAssertNotNil(rawData)
        XCTAssertNil(String(data: rawData!, encoding: .utf8), "Since the data is encrypted, simply decoding it as `utf8` won't be possible, thus it must be nil.")
        let unarchivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawData!) as? Data
        XCTAssertNil(unarchivedData, "Since the data is encrypted, simply unarchiving it using NSKeyedUnarchiver won't be possible, thus it must be nil.")
        XCTAssertEqual(sut.secret, secret)
    }

    func test_erase_keyValue_shouldMakeWrapperReturnNilOrDefaultValues() throws {
        let testString = Defaults<String?>(container: DefaultsStorageTests.mockedDefaults, key: "string")
        let testOptionalInteger = Defaults(container: DefaultsStorageTests.mockedDefaults, key: "non_optional_integer", defaultValue: 18)

        XCTAssertNil(testString.wrappedValue)
        XCTAssertEqual(testOptionalInteger.wrappedValue, 18)

        testString.wrappedValue = "value"
        XCTAssertEqual(testString.wrappedValue, "value")
        XCTAssertEqual(DefaultsStorageTests.mockedDefaults.object(forKey: "string") as? String, "value")
        testOptionalInteger.wrappedValue = 100
        XCTAssertEqual(testOptionalInteger.wrappedValue, 100)
        XCTAssertEqual(DefaultsStorageTests.mockedDefaults.object(forKey: "non_optional_integer") as? Int, 100)

        try testString.erase()
        try testOptionalInteger.erase()
        XCTAssertNil(testString.wrappedValue)
        XCTAssertNil(DefaultsStorageTests.mockedDefaults.object(forKey: "string") as? String)
        XCTAssertEqual(testOptionalInteger.wrappedValue, 18)
        XCTAssertNil(DefaultsStorageTests.mockedDefaults.object(forKey: "non_optional_integer") as? Int)
    }
}
