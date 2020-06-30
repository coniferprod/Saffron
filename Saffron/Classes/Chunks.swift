import Foundation

public typealias ChunkData = FixedSizeArray<Byte>

public protocol Chunk {
    var name: String { get set }
    var size: DWord { get }  // chunk size in bytes, including header
    var data: ChunkData { get set }    // chunk data
    
    init(name: String, data: ChunkData)  // chunk with name and data
    init(name: String, dataSize: Int)
}

// Represents a chunk in the RIFF protocol
public class Chunk: CustomStringConvertible {
    public var name: String   // chunk name (will have to convert this to and from FourCC)
    public var size: DWord { // chunk size in bytes, including header
        get {
            var chunkSize = self.data.size
            if chunkSize % 2 != 0 {
                chunkSize += 1
            }
            return DWord(8 + chunkSize)
        }
    }
    private var data: ChunkData  // chunk data (fixed size array)
    
    public init(name: String, data: ChunkData) {
        self.name = name
        self.data = data
        //self.size = DWord(data.size)
    }
    
    public init(name: String, dataSize: Int) {
        self.name = name
        self.data = ChunkData(maxSize: dataSize, initialValue: 0)
        //self.size = DWord(dataSize)
    }
    
    public var description: String {
        return self.name
    }
}

// 'Two types of chunks, the “RIFF” and “LIST” chunks, may contain nested chunks called sub-chunks as their data.' (SoundFont specification, section 3.1)

/// A chunk with sub-chunks.
public class ListChunk: Chunk {
    var subchunks: [Chunk]

    public init(name: String) {
        subchunks = [Chunk]()
        super.init(name: name, dataSize: 0)
    }
    
    public init(name: String, subchunks: [Chunk]) {
        self.subchunks = subchunks
        let totalSubchunkSize = subchunks.reduce(0, {$0 + $1.size})
        let subchunkData = ChunkData(maxSize: Int(totalSubchunkSize), initialValue: 0)
        
        super.init(name: name, data: subchunkData)
    }
    
    public override var description: String {
        let chunkName = self.name
        var buf = "\(chunkName):\n"
        for chunk in subchunks {
            buf += "    \(chunk)\n"
        }
        return buf
    }
    
    public func addSubchunk(chunk: Chunk) {
        self.subchunks.append(chunk)
    }
}

public class InfoListChunk: ListChunk {
    let defaultEngine = "EMU8000"
    
    public init() {
        var chunks = [Chunk]()
        let versionData = ChunkData(maxSize: 4, initialValue: 0)
        let versionChunk = Chunk(name: "ifil", data: versionData)
        chunks.append(versionChunk)

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

public class SdtaListChunk: ListChunk {
    var samples: [Sample]
    
    var samplePoolSize: DWord {
        get {
            var size = 0
            for sample in self.samples {
                size += UInt16.byteWidth * sample.data.size + Limits.terminatorSampleLength
                if size > UInt32.max {
                    //throw SoundFontError.samplePoolOverflow
                    // TODO: handle the error
                }
            }
            return DWord(size)
        }
    }
    
    override public var size: DWord {
        return DWord(8 + samplePoolSize)
    }
    
    public init(samples: [Sample]) {
        self.name = "sdta"
        
        self.samples = samples

        //super.init(name: "smpl", dataSize: Int(samplePoolSize))


        // TODO: Prepare the chunk data
                
        for sample in self.samples {
            
        }
        
    }
}

public class PdtaListChunk: ListChunk {
    public init() {
        super.init(name: "pdta")
        
    }
}

public class PresetHeaderChunk: Chunk {
    let itemSize = 38  // the item size of "phdr" chunk
    
    var presets: [Preset]
    
    override public var size: DWord {
        return DWord(8 + itemSize * presets.count)
    }
    
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
    
    
public class VersionChunk: Chunk {
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
