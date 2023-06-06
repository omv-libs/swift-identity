//
//  StronglyTypedID+TestingTests.swift
//
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import StronglyTypedID
import XCTest

final class StronglyTypedID_TestingTests: XCTestCase {
    // Not really testing much of anything but verifying that the type system wrangling produces the desired result.
    // If the extension of `TestStringIDType` adopting `ExpressibleByStringLiteral` is removed the test won't compile.
    func testExpressibleByStringLiteralID() {
        // This only builds if TestStringIDType is declared as adopting `ExpressibleByStringLiteral`
        let dummyID1: TestStringIDType = "Potato"

        XCTAssertEqual(dummyID1, "Potato")

        // This only builds if TestStringIDType is declared as adopting `ExpressibleByStringInterpolation`
        let dummyID2: TestStringIDType = "Another \(dummyID1)"

        XCTAssertEqual(dummyID2, "Another Potato")
    }
}

struct TestStringIDType: StronglyTypedID, Comparable {
    var rawValue: String
}

extension TestStringIDType: ExpressibleByStringLiteral {}

extension TestStringIDType: ExpressibleByStringInterpolation {}
