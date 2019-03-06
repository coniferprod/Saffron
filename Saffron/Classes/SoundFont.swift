import Foundation

public struct Version {
    let major: UInt16
    let minor: UInt16
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
    var soundROMVersion: Version?
    
    var presets = [Preset]()
    var instruments = [Instrument]()
    var samples = [Sample]()
    
    public init() {
        self.soundEngineName = "Unknown"
        self.bankName = "unknown"
    }
    
    public func write(fileName: String) throws {
        var riff = RIFF(name: "sfbk")
        
        riff.addChunk(makeInfoListChunk())
        riff.addChunk(makeSdtaListChunk())
        riff.addChunk(makePdtaListChunk())

        // TODO: Write everything to output file
    }
    
    private func stringUpToLimit(s: String, maxLength: Int) -> String {
        let start = s.startIndex
        let end = s.index(s.startIndex, offsetBy: min(s.count, maxLength))
        return String(s[start..<end])
    }
    
    private func makeInfoListChunk() -> ListChunk {
        var subchunks = [Chunk]()
        subchunks.append(makeVersionChunk(name: "ifil", version: Version(major: 2, minor: 1)))
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
        
        return ListChunk(name: "pdta", subchunks: subchunks)
    }
    
    private func makeVersionChunk(name: String, version: Version) -> Chunk {
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

