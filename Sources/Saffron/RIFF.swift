import Foundation

public protocol Chunk {
    var name: String { get }  // chunk type identifier (converted to FourCC as necessary)
    var size: DWord { get } // chunk size field (size of data in bytes)
    var data: ByteArray { get }  // the actual data plus a pad byte if required to word align
}

public class RIFFChunk: Chunk {  // like `class RIFFChunk` in sf2cute
    var _name: String
    var _data: ByteArray
    
    /// Constructs a new RIFFChunk using the specified name and possibly data.
    public init(name: String, data: ByteArray = []) {
        self._name = name
        self._data = data
    }
    
    public var name: String {
        return _name
    }
    
    // Can only set the data when constructing an instance.
    
    private var header: ByteArray {
        var result = ByteArray()
        
        let nameFourCC = self.name.toFourCC()
        result.append(contentsOf: nameFourCC.bytesBE)
        
        result.append(contentsOf: self.size.bytesLE)

        return result
    }
    
    public var data: ByteArray {
        var result = ByteArray()

        result.append(contentsOf: self.header)
        
        result.append(contentsOf: self._data)
        
        if self.size % 2 != 0 {
            result.append(Byte(0x00))
        }
        
        return result
    }
    
    /// Returns the whole length of this chunk, including a chunk header, in bytes.
    public var size: DWord {
        var sz = self._data.count
        if sz % 2 != 0 {
            sz += 1
        }
        return DWord(8 + sz)
    }
}

extension RIFFChunk: CustomStringConvertible {
    public var description: String {
        return name
    }
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

/// Represents a RIFF file.
public class RIFF {
    let riffString = "RIFF"
    
    var _name: String  // RIFF form name, like 'sfbk'
    var _chunks: [Chunk]
    
    /// Constructs a new empty RIFF using the specified form type.
    public init(name: String) {
        self._name = name
        self._chunks = []
    }

    /// Returns the form type of this chunk.
    public var name: String {
        return _name
    }
    
    public var chunks: [Chunk] {
        return _chunks
    }
    
    public func addChunk(chunk: Chunk) {
        self._chunks.append(chunk)
    }
    
    public func clearChunks() {
        self._chunks.removeAll()
    }


    func showChunks() {
        print("\(riffString): \(name)")
        for chunk in self.chunks {
            print(chunk)
        }
    }
    
    /// Returns the whole length of this RIFF including a chunk header.
    public var size: DWord {
        var sz = 0
        for chunk in self._chunks {
            sz += Int(chunk.size)
        }
        return DWord(12 + sz)
    }
    
    var header: ByteArray {
        var result = ByteArray()
        
        let riffFourCC = "RIFF".toFourCC()
        let nameFourCC = self.name.toFourCC()

        result.append(contentsOf: riffFourCC.bytesBE)
        result.append(contentsOf: self.size.bytesLE)
        
        result.append(contentsOf: nameFourCC.bytesBE)

        return result
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        
        result.append(contentsOf: self.header)
        
        for chunk in self._chunks {
            result.append(contentsOf: chunk.data)
        }

        return result
    }
}

extension RIFF: CustomStringConvertible {
    public var description: String {
        var result = "RIFF( \(self.name)"
        
        for chunk in self.chunks {
            result += "\(chunk) "
        }
        
        result += ")"
        
        return result
    }
}

