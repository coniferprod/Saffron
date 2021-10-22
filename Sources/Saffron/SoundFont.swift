import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord
public typealias Short = Int16
public typealias Char = Int8

public typealias ByteArray = [Byte]

// From https://stackoverflow.com/a/47221437/1016326
extension FixedWidthInteger {
    var byteWidth: Int {
        return self.bitWidth / UInt8.bitWidth
    }
    static var byteWidth: Int {
        return Self.bitWidth / UInt8.bitWidth
    }
}

// Adapted from https://stackoverflow.com/a/47513234/1016326
extension String {
    public init(fourCC: FourCC) {
        let n = Int(fourCC)
        var s = ""
        
        let unicodes = [
            UnicodeScalar((n >> 24) & 255),
            UnicodeScalar((n >> 16) & 255),
            UnicodeScalar((n >> 8) & 255),
            UnicodeScalar(n & 255)
        ]
        unicodes.compactMap { (unicode) -> String? in
            guard let unicode = unicode else {
                return nil
            }
            return String(unicode)
        }.forEach { (unicode) in
            s.append(unicode)
        }
        
        self = s.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // Convert from string to FourCC (thanks, AudioKit!)
    public func toFourCC() -> FourCC {
        let utf8 = self.utf8
        precondition(utf8.count == 4, "Must be a four-character string")
        var out: UInt32 = 0
        for char in utf8 {
            out <<= 8
            out |= UInt32(char)
        }
        return out
    }
}

func _convertToBytes<T>(_ value: T, withCapacity capacity: Int) -> [UInt8] {
    var mutableValue = value
    return withUnsafePointer(to: &mutableValue) {
        return $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {
            return Array(UnsafeBufferPointer(start: $0, count: capacity))
        }
    }
}

extension UInt16 {
    var bytes: [UInt8] {
        return _convertToBytes(self, withCapacity: MemoryLayout<Self>.size)
    }
    
    init?(_ bytes: [UInt8]) {
        guard bytes.count == MemoryLayout<Self>.size else { return nil }
        self = bytes.withUnsafeBytes {
            return $0.load(as: Self.self)
        }
    }
}

public struct VersionTag {
    let major: Word
    let minor: Word
    
    public init(major: Word, minor: Word) {
        self.major = major
        self.minor = minor
    }
    
    public func asData() -> ChunkData {
        var result = ChunkData()
        result.append(contentsOf: self.major.littleEndian.bytes)
        result.append(contentsOf: self.minor.littleEndian.bytes)
        return result
    }
}

public struct Limits {
    static let infoTextMaxLength = 256 - 1 // max length of info chunk text minus zero terminator
    static let terminatorSampleLength = 46 // the length of terminator samples, in sample data points
    static let sampleNamMaxLength = 20 - 1 // max length of sample name (excluding the terminator byte)
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

    var riff: RIFFChunk
    
    public init() {
        self.soundEngineName = "Unknown"
        self.bankName = "unknown"
        
        let infoListChunk = InfoListChunk()
        let sampleDataChunk = SampleDataListChunk()
        let presetDataChunk = PresetDataListChunk()
        
        self.riff = RIFFChunk(subchunks: [infoListChunk, sampleDataChunk, presetDataChunk])
        //self.riff.addChunk(makeInfoListChunk())
        //self.riff.addChunk(makeSdtaListChunk())
        //self.riff.addChunk(makePdtaListChunk())
    }
    
    public func write(fileName: String) throws {

        // TODO: Write everything to output file
    }
    
    private func stringUpToLimit(s: String, maxLength: Int) -> String {
        let start = s.startIndex
        let end = s.index(s.startIndex, offsetBy: min(s.count, maxLength))
        return String(s[start..<end])
    }
    
    private func makeInfoListChunk() -> ListChunk {
        var subchunks = [Chunk]()
        subchunks.append(makeVersionChunk(name: "ifil", version: VersionTag(major: 2, minor: 1)))
        subchunks.append(makeZSTRChunk(name: "isng", data: stringUpToLimit(s: self.soundEngineName, maxLength: Limits.infoTextMaxLength)))
        subchunks.append(makeZSTRChunk(name: "INAM", data: stringUpToLimit(s: self.bankName, maxLength: Limits.infoTextMaxLength)))
        
        // Optional chunks:
        if let soundROMName = self.soundROMName {
            subchunks.append(makeZSTRChunk(name: "irom", data: stringUpToLimit(s: soundROMName, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let soundROMVersion = self.soundROMVersion {
            subchunks.append(makeVersionChunk(name: "iver", version: soundROMVersion))
        }
        
        if let creationDate = self.creationDate {
            subchunks.append(makeZSTRChunk(name: "ICRD", data: stringUpToLimit(s: creationDate, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let designers = self.designers {
            subchunks.append(makeZSTRChunk(name: "IENG", data: stringUpToLimit(s: designers, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let productName = self.productName {
            subchunks.append(makeZSTRChunk(name: "IPRD", data: stringUpToLimit(s: productName, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let copyright = self.copyright {
            subchunks.append(makeZSTRChunk(name: "ICOP", data: stringUpToLimit(s: copyright, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let comments = self.comments {
            subchunks.append(makeZSTRChunk(name: "ICMT", data: stringUpToLimit(s: comments, maxLength: Limits.infoTextMaxLength)))
        }
        
        if let software = self.software {
            subchunks.append(makeZSTRChunk(name: "ISFT", data: stringUpToLimit(s: software, maxLength: Limits.infoTextMaxLength)))
        }

        return ListChunk(name: "INFO", subchunks: subchunks)
    }
    
    private func makeSdtaListChunk() -> ListChunk {
        var subchunks = [Chunk]()
        
        subchunks.append(SampleChunk(samples: self.samples))
     
        return ListChunk(name: "sdta", subchunks: subchunks)
    }
    
    private func makePdtaListChunk() -> ListChunk {
        var subchunks = [Chunk]()

        // TODO: Handle pdta
        // PHDR, PBAG, PMOD, PGEN, INST, IBAG, IMOD, IGEN, SHDR
        subchunks.append(PresetHeaderChunk(presets: self.presets))
        /*
        subchunks.append(PresetZoneChunk(presets: self.presets))
        subchunks.append(PresetZoneModulatorChunk(presets: self.presets))
        subchunks.append(PresetZoneGeneratorChunk(presets: self.presets))
        subchunks.append(InstrumentHeaderChunk(instruments: self.instruments))
        subchunks.append(InstrumentZoneChunk(instruments: self.instruments))
        subchunks.append(InstrumentZoneModulatorChunk(instruments: self.instruments))
        subchunks.append(InstrumentZoneGeneratorChunk(instruments: self.instruments))
        subchunks.append(SampleHeaderChunk(samples: self.samples))
        */
        
        return ListChunk(name: "pdta", subchunks: subchunks)
    }
    
    private func makeVersionChunk(name: String, version: VersionTag) -> Chunk {
        let versionData = ChunkData(maxSize: 4, initialValue: 0)
        return Chunk(name: name, data: versionData)
    }
    
    // Make a chunk with a zero-terminated string as data
    private func makeZSTRChunk(name: String, data: String) -> Chunk {
        // Get the bytes from the string (ASCII-only, so UTF-8 should be fine)
        let buf: [Byte] = Array(data.utf8)
        
        // Make a fized-size array with room for the terminating zero.
        // The array elements are initialized to zero, so there is no need to set the terminator.
        var stringData = ChunkData(maxSize: buf.count + 1, initialValue: 0)
        
        // Copy the bytes of the string over
        for (i, b) in buf.enumerated() {
            try! stringData.set(index: i, b)
        }
        
        return Chunk(name: name, data: stringData)
    }
    
    fileprivate let defaultSoundEngine = "EMU8000"
    fileprivate let defaultBankName = "Untitled"
}

extension SoundFont: CustomStringConvertible {
    public var description: String {
        var buf = ""
        buf += "Bank = \(self.bankName)\n"
        buf += "Engine = \(self.bankName)\n\n"
        buf += "\(self.riff)\n"
        return buf
    }
}
