import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord
public typealias Short = Int16
public typealias Char = Int8

public typealias ByteArray = [Byte]

// Zero-terminated string for RIFF (ZSTR)
struct ZStr {
    let value: String
    
    var bytes: ByteArray {
        get {
            var result = ByteArray()
            for ch in value {
                result.append(ch.asciiValue ?? 0x20)
            }
            return result
        }
    }
}

public struct Ranges {
    let low: Byte
    let high: Byte
    
    public init(low: Byte, high: Byte) {
        self.low = low
        self.high = high
    }
}


enum SoundFontError: Error {
    case samplePoolOverflow
}


extension FixedWidthInteger {
    var bytes: ByteArray {
        withUnsafeBytes(of: littleEndian, Array.init)
    }
}

extension String {
    // Convert from string to FourCC (thanks, AudioKit!)
    public func toFourCC() -> FourCC {
        guard self.utf8.count == 4 else {
            return 0
        }
        
        var out: UInt32 = 0
        for char in self.utf8 {
            out <<= 8
            out |= UInt32(char)
        }
        
        return out
    }
}

public struct VersionTag {
    let major: Word
    let minor: Word
    
    public init(major: Word, minor: Word) {
        self.major = major
        self.minor = minor
    }
    
    public var bytes: ByteArray {
        var result = ByteArray()
        result.append(contentsOf: self.major.littleEndian.bytes)
        result.append(contentsOf: self.minor.littleEndian.bytes)
        return result
    }
}

public struct Limits {
    static let infoTextMaxLength = 256 - 1 // max length of info chunk text minus zero terminator
    static let terminatorSampleLength = 46 // the length of terminator samples, in sample data points
    static let sampleNameMaxLength = 20 - 1 // max length of sample name (excluding the terminator byte)
}

extension Character {
    var isAscii: Bool {
        return unicodeScalars.first?.isASCII == true
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension StringProtocol {
    var ascii: [UInt32] {
        return compactMap { $0.ascii }
    }
}

public class SoundFont {
    public var soundEngineName: String
    public var bankName: String
    public var soundROMName: String?
    var creationDate: String?
    var designers: String?
    var productName: String?
    var copyright: String?
    var comments: String?
    var software: String?
    var soundROMVersion: VersionTag?
    
    var presets = [Preset]()
    var instruments = [Instrument]()
    var samples = [Sample]()
    
    public init() {
        self.soundEngineName = "Unknown"
        self.bankName = "unknown"
        
        let infoListChunk = ListChunk(
            name: "INFO",
            children: [
                FileVersion(VersionTag(major: 2, minor: 0)), // Mandatory 'ifil' subchunk
                // Optional 'isng' subchunk is ignored for now
                BankName("General MIDI"),  // mandatory INAM
                // No ROM samples, so ignore the IROM and iver subchunks
                CreationDate("October 19, 2022"),  // ICRD
                // Ignore IENG, IPRD, ICOP, ICMT, and ISFT subchunks for now
            ]
        )
        
        // The sdta-list chunk contains a single optional smpl sub-chunk
        // which contains all the RAM based sound data.
        let sampleDataChunk = ListChunk(name: "sdta", children: [])
        
        let presetDataChunk = ListChunk(name: "pdta", children: [])
    }
        
    private func stringUpToLimit(s: String, maxLength: Int) -> String {
        let start = s.startIndex
        let end = s.index(s.startIndex, offsetBy: min(s.count, maxLength))
        return String(s[start..<end])
    }
    
    fileprivate let defaultSoundEngine = "EMU8000"
    fileprivate let defaultBankName = "Untitled"
}

extension SoundFont: CustomStringConvertible {
    public var description: String {
        var buf = ""
        buf += "Bank = \(self.bankName)\n"
        buf += "Engine = \(self.bankName)\n\n"
        //buf += "\(self.riff)\n"
        return buf
    }
}
