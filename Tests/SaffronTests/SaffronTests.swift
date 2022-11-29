import XCTest
@testable import Saffron

final class SaffronTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testFourCCFromString() {
        let riffString = "RIFF"
        let fourCC = riffString.toFourCC()
        XCTAssertEqual(fourCC, 0x52494646)
    }
    
    func testByteArrayFromFourCC() {
        let fourCC: FourCC = 0x46464952
        let ba = fourCC.bytes
        XCTAssertEqual(ba, [0x52, 0x49, 0x46, 0x46])
    }
    
    func testByteArrayFromDWordLE() {
        let size: DWord = 0x01DD501A  // 31_281_178, in file as LE: 1A 50 DD 01
        let ba = size.bytes
        XCTAssertEqual(ba, [0x1A, 0x50, 0xDD, 0x01])
    }
    
}
