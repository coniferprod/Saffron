import Foundation

// Represents a chunk in the RIFF protocol
public protocol RIFFChunk {
    var name: FourCC { get set }  // chunk name (FourCC)
    var size: DWord { get set }  // chunk size in bytes, including header
    var data: Data { get set }    // chunk data
    
    init(name: String)   // empty chunk with name
    init(name: String, data: Data)  // chunk with name and data
    
    func write(out: OutputStream) throws  // write chunk to stream
}

public class Chunk: RIFFChunk {
    public var name: FourCC
    public var size: DWord
    public var data: Data
    
    required public init(name: String) {
        self.name = fourCC(name)
    }
    
    required public init(name: String, data: Data) {
        self.name = fourCC(name)
        self.data = data
    }
    
    public func write(out: OutputStream) throws {
        
    }
    
    
}
