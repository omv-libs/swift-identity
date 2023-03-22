import XCTest
import StronglyTypedID

final class StronglyTypedIDTests: XCTestCase {
    // Mostly testing that the Swift type system does what we expect.
    func testComparableStronglyTypedID() {
        struct DummyIDType: StronglyTypedID, Comparable {
            var rawValue: Int
        }

        let dummyID1 = DummyIDType(rawValue: 7)
        let dummyID2 = DummyIDType(rawValue: 77)

        XCTAssert(dummyID1 < dummyID2)
    }
}
