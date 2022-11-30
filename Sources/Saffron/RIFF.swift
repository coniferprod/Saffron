import Foundation

public protocol Chunk {
    var name: String { get }  // chunk type identifier (converted to FourCC as necessary)
    var size: DWord { get } // chunk size field (size of data in bytes)
    var data: ByteArray { get }  // the actual data plus a pad byte if required to word align
}

/// A chunk with sub-chunks.
public class ListChunk {
    public var name: String

    public var children: [Chunk]
    
    public init(name: String, children: [Chunk]) {
        self.name = name
        self.children = children
    }
}

extension ListChunk: Chunk {
    public var size: DWord {
        var result: DWord = 0
        for child in children {
            result += child.size
        }
        return result
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        for chunk in self.children {
            result.append(contentsOf: chunk.data)
        }
        return result
    }
}

extension ListChunk: CustomStringConvertible {
    public var description: String {
        return "LIST: \(name)"
    }
}

public struct RIFF {
    var name: String  // RIFF form name, like 'sfbk'
    var chunks: [Chunk]
    
    func showChunks() {
        print("RIFF: \(name)")
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
        let riffFourCC = "RIFF".toFourCC()
        let nameFourCC = self.name.toFourCC()

        var result = [UInt8]()
        result.append(contentsOf: riffFourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)

        result.append(contentsOf: nameFourCC.littleEndian.bytes)

        for chunk in self.chunks {
            result.append(contentsOf: chunk.data)
        }
        
        return result
    }
}

