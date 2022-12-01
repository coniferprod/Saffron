import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord
public typealias Short = Int16
public typealias Char = Int8

public typealias ByteArray = [Byte]

/// Zero-terminated string for RIFF (ZSTR)
public struct ZStr {
    public let value: String
    
    public var bytes: ByteArray {
        get {
            var result = ByteArray()
            for ch in value {
                result.append(ch.asciiValue ?? 0x20)
            }
            result.append(0x00)  // add terminator
            if result.count % 2 != 0 {
                result.append(0x00)  // make count even
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
    public var bytesBE: ByteArray {
        withUnsafeBytes(of: bigEndian, Array.init)
    }
    
    public var bytesLE: ByteArray {
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
        self.soundEngineName = defaultSoundEngine
        self.bankName = defaultBankName
        
    }
    
    public init(samples: [Sample]) {
        self.soundEngineName = defaultSoundEngine
        self.bankName = defaultBankName

        self.samples = samples
    }
        
    private func stringUpToLimit(s: String, maxLength: Int) -> String {
        let start = s.startIndex
        let end = s.index(s.startIndex, offsetBy: min(s.count, maxLength))
        return String(s[start..<end])
    }
    
    fileprivate let defaultSoundEngine = "EMU8000"
    fileprivate let defaultBankName = "Untitled"
    
    public func makeInfoListChunk() -> RIFFListChunk {
        var info = RIFFListChunk(name: "INFO")
        
        //
        // Mandatory chunks
        //
        
        info.addSubchunk(subchunk: VersionChunk(version: VersionTag(major: 2, minor: 1)))
        info.addSubchunk(subchunk: makeZStrChunk(name: "isng", value: self.soundEngineName))
        info.addSubchunk(subchunk: makeZStrChunk(name: "INAM", value: self.bankName))
        
        //
        // Optional chunks
        //

        if let romName = self.soundROMName {
            info.addSubchunk(subchunk: makeZStrChunk(name: "irom", value: romName))
        }
        
        if let romVersion = self.soundROMVersion {
            info.addSubchunk(subchunk: VersionChunk(version: romVersion))
        }
        
        if let creationDate = self.creationDate {
            info.addSubchunk(subchunk: makeZStrChunk(name: "ICRD", value: creationDate))
        }
        
        if let designers = self.designers {
            info.addSubchunk(subchunk: makeZStrChunk(name: "IENG", value: designers))
        }
        
        if let copyright = self.copyright {
            info.addSubchunk(subchunk: makeZStrChunk(name: "ICOP", value: copyright))
        }
        
        if let comments = self.comments {
            info.addSubchunk(subchunk: makeZStrChunk(name: "ICMT", value: comments))
        }
        
        if let software = self.software {
            info.addSubchunk(subchunk: makeZStrChunk(name: "ISFT", value: software))
        }
        
        return info
    }
    

    func makeZStrChunk(name: String, value: String) -> RIFFChunk {
        return RIFFChunk(name: name, data: ZStr(value: value).bytes)
    }
    
    func makeRIFF() -> RIFF {
        var riff = RIFF(name: "sfbk")
        riff.addChunk(chunk: self.makeInfoListChunk())
        return riff
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        
        let riff = makeRIFF()
        
        result.append(contentsOf: riff.data)
        
        return result
    }
}

extension SoundFont: CustomStringConvertible {
    public var description: String {
        var lines = [String]()
        
        lines.append("Bank = \(self.bankName)")
        lines.append("Engine = \(self.bankName)")
        lines.append("Sound ROM = \(self.soundROMName ?? "N/A")")
        
        return lines.joined(separator: "\n")
    }
}
