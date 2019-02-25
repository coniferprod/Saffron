import Foundation

public class RIFF {
    var name: String
    var chunks: [Chunk]
    
    public init() {
        self.name = "    "
        self.chunks = [Chunk]()
        
    }
    
    public func addChunk(chunk: Chunk) {
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
    
    public func write(out: OutputStream) throws {
        writeHeader(out: out, name: name, size: )
        
        for c in self.chunks {
            c.write(out: out)
        }
    }
    
}
