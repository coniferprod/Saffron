import Foundation

public typealias ChunkData = FixedSizeArray<Byte>

/*
public protocol Chunk {
    var name: FourCC { get set }
    var size: DWord { get }  // chunk size in bytes, including header
    var data: ChunkData { get set }    // chunk data
    
    init(name: String, data: ChunkData)  // chunk with name and data
    init(name: String, dataSize: Int)
    
    func write(out: OutputStream) throws  // write chunk to stream
}
*/

// Represents a chunk in the RIFF protocol
public class Chunk {
    public var name: FourCC   // chunk name (FourCC)
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
        self.name = fourCC(name)
        self.data = data
        //self.size = DWord(data.size)
    }
    
    public init(name: String, dataSize: Int) {
        self.name = fourCC(name)
        self.data = ChunkData(maxSize: dataSize, initialValue: 0)
        //self.size = DWord(dataSize)
    }
    
}

// 'Two types of chunks, the “RIFF” and “LIST” chunks, may contain nested chunks called sub-chunks as their data.' (SoundFont specification, section 3.1)

/*
public class RIFFChunk: ChunkBase {
    public func write(out: OutputStream) throws {
        
    }
    
}
*/

public class ListChunk: Chunk {
    var subchunks: [Chunk]
    
    public init(name: String, subchunks: [Chunk]) {
        self.subchunks = subchunks
        let totalSubchunkSize = subchunks.reduce(0, {$0 + $1.size})
        let subchunkData = ChunkData(maxSize: Int(totalSubchunkSize), initialValue: 0)
        
        super.init(name: name, data: subchunkData)
    }
    
}

enum SoundFontError: Error {
    case samplePoolOverflow
}

public class SampleChunk: Chunk {
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
        self.samples = samples

        // TODO: Prepare the chunk data
        
        
        for sample in self.samples {
            
        }
        
        super.init(name: "smpl", dataSize: Int(samplePoolSize))
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
        
        // TODO: Prepare the chunk data
        
        super.init(name: "phdr", dataSize: Int(size))
    }
    
    
}




