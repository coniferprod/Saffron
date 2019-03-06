import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord

// From https://stackoverflow.com/a/47221437/1016326
extension FixedWidthInteger {
    var byteWidth: Int {
        return self.bitWidth / UInt8.bitWidth
    }
    static var byteWidth: Int {
        return Self.bitWidth / UInt8.bitWidth
    }
}

public class RIFF {
    var name: String
    var chunks: [Chunk]
    
    public init() {
        self.name = "    "
        self.chunks = [Chunk]()
    }
    
    public init(name: String) {
        self.name = name
        self.chunks = [Chunk]()
    }
    
    public func addChunk(_ chunk: Chunk) {
        self.chunks.append(chunk)
    }
    
    public func clearChunks() {
        self.chunks.removeAll()
    }
    
    // Returns the length of the RIFF file, including the chunk header
    public var size: DWord {
        get {
            var totalSize: DWord = 0
            for c in self.chunks {
                totalSize += c.size
            }
            return totalSize + 12
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: DWord) {
        
        
    }
    
    /*
    public func write(out: OutputStream) throws {
        writeHeader(out: out, name: name, size: )
        
        for c in self.chunks {
            c.write(out: out)
        }
    }
    */
    
}

public func fourCC(_ string: String) -> FourCC {
    let utf8 = string.utf8
    precondition(utf8.count == 4, "Must be a four-character string")
    var out: UInt32 = 0
    for char in utf8 {
        out <<= 8
        out |= UInt32(char)
    }
    return out
}
