import Foundation

/// Represents a chunk in the RIFF protocol
public class Chunk {
    public var name: String  // chunk type identifier (converted to FourCC as necessary)
    public var size: DWord  // chunk size field (size of data in bytes)
    public var data: ByteArray  // chunk data

    public init(name: String, size: DWord, data: ByteArray) {
        self.name = name
        self.size = size
        self.data = data
    }
}

extension Chunk: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}

/// A chunk with sub-chunks.
public class ListChunk {
    public var name: String   // chunk name (will have to convert this to and from FourCC)
    public var subchunks: [Chunk]

    public init(name: String) {
        self.name = name
        self.subchunks = [Chunk]()
    }
    
    public init(name: String, subchunks: [Chunk]) {
        self.name = name
        self.subchunks = subchunks
    }
    
    public func addSubchunk(chunk: Chunk) {
        self.subchunks.append(chunk)
    }
}

extension ListChunk: CustomStringConvertible {
    public var description: String {
        let chunkName = self.name
        var buf = "\(chunkName):\n"
        for chunk in subchunks {
            buf += "    \(chunk)\n"
        }
        return buf
    }
}

public class InfoListChunk: ListChunk {
    let defaultEngine = "EMU8000"
    
    public init() {
        var chunks = [Chunk]()
        
        // Mandatory 'ifil' subchunk:
        let versionTag = VersionTag(major: 2, minor: 0)
        let data = versionTag.asData()
        let versionChunk = Chunk(name: "ifil", size: DWord(data.count), data: data)
        chunks.append(versionChunk)

        // Optional 'isng' subchunk is ignored for now
        
        // INAM (mandatory)
        var nameData = ChunkData()
        nameData.append(contentsOf: "General MIDI".utf8)
        chunks.append(Chunk(name: "INAM", size: 12, data: nameData))
        
        // No ROM samples, so ignore the IROM and iver subchunks
        
        var creationData = ChunkData()
        creationData.append(contentsOf: "April 10, 2021".utf8) // byte count is even
        chunks.append(Chunk(name: "ICRD", size: 14, data: creationData))
        
        // Ignore IENG, IPRD, ICOP, ICMT, and ISFT subchunks.
        
        super.init(name: "INFO", subchunks: chunks)
    }
}

enum SoundFontError: Error {
    case samplePoolOverflow
}

public class SampleSubChunk: Chunk {
    var samples: [Short]
    
    public init(data: Data) {
        self.name = "smpl"
        
    }
        
}

public class SampleDataListChunk: ListChunk {
    var samples: [Sample]
    
    var samplePoolSize: DWord {
        get {
            var size = 0
            for sample in self.samples {
                size += UInt16.byteWidth * sample.data.count + Limits.terminatorSampleLength
                if size > UInt32.max {
                    //throw SoundFontError.samplePoolOverflow
                    // TODO: handle the error
                }
            }
            return DWord(size)
        }
    }
    
    public init(samples: [Sample]) {
        self.samples = samples

        var chunks = [Chunk]()
        for sample in self.samples {
            chunks.append(Chunk(name: "smpl", size: 0, data: ChunkData()))
        }
        
        super.init(name: "sdta", subchunks: chunks)
    }
}

public class PresetDataListChunk: ListChunk {
    public init() {
        super.init(name: "pdta")
        
    }
}

public class PresetHeaderChunk: Chunk {
    let itemSize = 38  // the item size of "phdr" chunk
    
    var presets: [Preset]
    
    public init(presets: [Preset]) {
        self.presets = presets
        
        //super.init(name: "phdr", dataSize: Int(size))
        super.init(name: "phdr", dataSize: 0)

        // TODO: Prepare the chunk data
    }    
}

public class PresetBagChunk: Chunk {
    let itemSize = 4  // the item size of "pbag" chunk

}

public class HeaderSubChunk: Chunk {
    var maxSize: Int
    
    private var fieldValue: [Byte]
    
    var field: String {
        get {
            
            
        }
        
        set {
            
        }
    }
    
    
    public init(subChunkName: String, maxSize: Int = 0x100) {
        self.name = subChunkName
        
        self.maxSize = maxSize
    }
    
    public override var description: String {
        let chunkName = self.name
        var buf = "Header chunk: name=\(chunkName), maxSize=\(maxSize)"
        return buf
    }
}
    
    
public class Version: Chunk {
    private var version: VersionTag
    
    public init(version: VersionTag) {
        self.name = "iver"
        self.version = version
        
        // Prepare the chunk data from the version struct
        var versionData = ChunkData(maxSize: 4, initialValue: 0)
        
        do {
            try versionData.set(index: 0, Byte(version.major >> 8))
            try versionData.set(index: 1, UInt8(version.major & 0x00ff))
            
            try versionData.set(index: 2, Byte(version.minor >> 8))
            try versionData.set(index: 3, UInt8(version.minor & 0x00ff))
        }
        catch {
            print("Index out of bounds")
        }
                
    }
}
