import Foundation

public typealias Byte = UInt8
public typealias Word = UInt16
public typealias DWord = UInt32
public typealias FourCC = DWord
public typealias Short = Int16

// From https://stackoverflow.com/a/47221437/1016326
extension FixedWidthInteger {
    var byteWidth: Int {
        return self.bitWidth / UInt8.bitWidth
    }
    static var byteWidth: Int {
        return Self.bitWidth / UInt8.bitWidth
    }
}

public class RIFFChunk: ListChunk {
    public init(subchunks: [Chunk]) {
        super.init(name: "sfbk", subchunks: subchunks)
        
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

// Adapted from https://stackoverflow.com/a/47513234/1016326
extension String {
    public init(fourCC: FourCC) {
        let n = Int(fourCC)
        var s = ""
        
        let unicodes = [
            UnicodeScalar((n >> 24) & 255),
            UnicodeScalar((n >> 16) & 255),
            UnicodeScalar((n >> 8) & 255),
            UnicodeScalar(n & 255)
        ]
        unicodes.compactMap { (unicode) -> String? in
            guard let unicode = unicode else {
                return nil
            }
            return String(unicode)
        }.forEach { (unicode) in
            s.append(unicode)
        }
        
        self = s.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // Convert from string to FourCC (thanks, AudioKit!)
    public func toFourCC() -> FourCC {
        let utf8 = self.utf8
        precondition(utf8.count == 4, "Must be a four-character string")
        var out: UInt32 = 0
        for char in utf8 {
            out <<= 8
            out |= UInt32(char)
        }
        return out
    }
}
