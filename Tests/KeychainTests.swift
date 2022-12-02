// Copyright © 2022 JARMourato All rights reserved.

@testable import StoragePlus
import XCTest

// Actual Keychain capabilities cannot be unit tested without a host application with keychain entitlement,
// thus, we're not going to unit test the integration with Valet.
final class KeychainTests: XCTestCase {
    func test_keychainKindSimple_shouldMatchIdentifierAndAccessibilityType() throws {
        let identifier = name
        let keychainKind = KeychainKind.simple(identifier: name)
        let container = keychainKind.createContainer() as? KeychainKind.KeychainContainer
        XCTAssertEqual(container?.valet.identifier.description, identifier)
        XCTAssertEqual(container?.valet.accessibility, .whenUnlocked)
    }
}
