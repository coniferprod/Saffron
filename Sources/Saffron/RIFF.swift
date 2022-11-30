import Foundation

public protocol Chunk {
    var name: String { get }  // chunk type identifier (converted to FourCC as necessary)
    var size: DWord { get } // chunk size field (size of data in bytes)
    var data: ByteArray { get }  // the actual data plus a pad byte if required to word align
}

public class RIFFListChunk: Chunk {
    var _name: String
    var subchunks: [Chunk]
    
    /// Constructs a new empty RIFFListChunk using the specified list type.
    public init(name: String) {
        self._name = name
        self.subchunks = []
    }

    /// Returns the name of this chunk.
    public var name: String {
        return _name
    }
    
    public func addSubchunk(subchunk: Chunk) {
        self.subchunks.append(subchunk)
    }
    
    public func clearSubchunks() {
        self.subchunks.removeAll()
    }
    
    public var size: DWord {
        var sz = 0
        for subchunk in self.subchunks {
            sz += Int(subchunk.size)
        }
        return DWord(12 + sz)
    }
    
    private var header: ByteArray {
        var result = ByteArray()

        let listFourCC = "LIST".toFourCC()
        result.append(contentsOf: listFourCC.bytesBE)

        result.append(contentsOf: self.size.bytesLE)

        let nameFourCC = self.name.toFourCC()
        result.append(contentsOf: nameFourCC.bytesBE)

        return result
    }
    
    public var data: ByteArray {
        var result = ByteArray()

        result.append(contentsOf: self.header)
        
        for subchunk in self.subchunks {
            result.append(contentsOf: subchunk.data)
        }
        
        return result
    }
}

public struct RIFF {
    let riffString = "RIFF"
    
    var name: String  // RIFF form name, like 'sfbk'
    var chunks: [Chunk]
    
    func showChunks() {
        print("\(riffString): \(name)")
        for chunk in self.chunks {
            print(chunk)
        }
    }
    
    var size: DWord {
        var result: DWord = 0
        for chunk in self.chunks {
            result += chunk.size
        }
        return result
    }
    
    var data: ByteArray {
        let riffFourCC = riffString.toFourCC()
        let nameFourCC = self.name.toFourCC()

        var result = [UInt8]()
        result.append(contentsOf: riffFourCC.bytesBE)
        result.append(contentsOf: self.size.bytesLE)

        result.append(contentsOf: nameFourCC.bytesBE)

        for chunk in self.chunks {
            result.append(contentsOf: chunk.data)
        }
        
        return result
    }
}
