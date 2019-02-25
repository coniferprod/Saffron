import Foundation

// These type definitions make it easier to correlate with the
// SoundFont technical specification.
public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord

public struct VersionTag {
    let major: UInt16
    let minor: UInt16
}

public class SoundFont {
    public var soundEngineName: String?
    public var bankName: String?
    public var soundROMName: String?
    var creationDate: String?
    var designers: String?
    var productName: String?
    var copyright: String?
    var comments: String?
    var software: String?
    
    var presets = [Preset]()
    var instruments = [Instrument]()
    var samples = [Sample]()
    
    public init() {
        
    }
    
    public func write(fileName: String) throws {
        
    }
    
    fileprivate let defaultSoundEngine = "EMU8000"
    fileprivate let defaultBankName = "Untitled"
}

public func fourCC(_ string: String) -> FourCC {
    let utf8 = string.utf8
    precondition(utf8.count == 4, "Must be a four-character string")
    var out: UInt32 = 0
    for char in utf8 {
        out <<= 8
        out |= UInt32(char)
    }
    return out
}

