import Foundation

// These type definitions make it easier to correlate with the
// SoundFont technical specification.
public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32

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
