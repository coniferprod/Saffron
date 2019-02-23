import Foundation

public typealias ChunkSize = Word

// Represents a chunk in the RIFF protocol
public protocol RIFFChunk {
    var name: String { get set }  // chunk name (FourCC)
    var size: ChunkSize { get set }  // chunk size in bytes, including header
    var data: Data { get set }    // chunk data
    
    init(name: String)   // empty chunk with name
    init(name: String, data: Data)  // chunk with name and data
    init(origin: RIFFChunk)  // copy of chunk from another (necessary?)
    
    func write(out: OutputStream) throws  // write chunk to stream
    static func writeHeader(out: OutputStream, name: String, size: ChunkSize)
}


