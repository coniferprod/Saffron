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

public class FileVersion {
    public let version: VersionTag

    public init(_ version: VersionTag) {
        self.version = version
    }
}

extension FileVersion: Chunk {
    public var name: String {
        get {
            return "ifil"
        }
    }
    
    public var size: DWord {
        return DWord(self.version.bytes.count)
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)
        result.append(contentsOf: self.version.bytes)
        return result
    }
}

public class BankName {
    public let bankName: String
    
    public init(_ bankName: String) {
        self.bankName = bankName
    }
}

extension BankName: Chunk {
    public var name: String {
        get {
            return "INAM"
        }
    }
    
    public var size: DWord {
        var sz = ZStr(value: self.bankName).bytes.count
        if sz % 2 != 0 {
            sz += 1
        }
        return DWord(8 + sz)
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)
        result.append(contentsOf: ZStr(value: self.bankName).bytes)
        return result
    }
}

public class CreationDate {
    public let creationDate: String

    public init(_ creationDate: String) {
        self.creationDate = creationDate
    }
}

extension CreationDate: Chunk {
    public var name: String {
        get {
            return "ICRD"
        }
    }
    
    public var size: DWord {
        var sz = ZStr(value: self.creationDate).bytes.count
        if sz % 2 != 0 {
            sz += 1
        }
        return DWord(8 + sz)
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)
        result.append(contentsOf: ZStr(value: self.creationDate).bytes)

        // Write a padding byte if necessary
        if result.count % 2 != 0 {
            result.append(0x00)
        }

        return result
    }
}

public func getSamplePoolSize(samples: [Sample]) -> DWord {
    var size = 0
    for sample in samples {
        size += UInt16.byteWidth * sample.data.count + Limits.terminatorSampleLength
        if size > UInt32.max {
            //throw SoundFontError.samplePoolOverflow
            // TODO: handle the error
        }
    }
    return DWord(size)
}

// The SHDR chunk is a required sub-chunk listing all samples within
// the smpl sub-chunk and any referenced ROM samples. It is always a
// multiple of forty-six bytes in length, and contains one record for
// each sample plus a terminal record according to the structure
public class SampleHeader {
    var samples: [Sample]
    
    public init(samples: [Sample]) {
        self.samples = samples
    }
}

extension SampleHeader: Chunk {
    public var name: String {
        get {
            return "SHDR"
        }
    }
    
    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

// The smpl sub-chunk contains one or more samples in the form of
// linearly coded sixteen bit, signed, little endian (least significant byte first) words.
// Each sample is followed by a minimum of forty-six zero valued sample data points.
public class SampleChunk {
    var samples: [Sample]
    
    public init() {
        self.samples = [Sample]()
    }
    
    public init(samples: [Sample]) {
        self.samples = samples
    }

    public var samplePoolSize: Int {
        var size = 0
        for sample in self.samples {
            size +=
            UInt16.byteWidth
            * (sample.data.count + Sample.terminatorSampleLength)
            
        }
        return size
    }
}

extension SampleChunk: Chunk {
    public var name: String {
        get {
            return "smpl"
        }
    }
    
    public var size: DWord {
        return DWord(self.samplePoolSize + 8)
    }

    public var data: ByteArray {
        var result = ByteArray()
        
        // Write the chunk data
        for sample in self.samples {
            // Write the samples
            for value in sample.data {
                // TODO: Write Int16 to out
            }
            
            // Write terminator samples
            for i in 0..<Sample.terminatorSampleLength {
                // TODO: Write zero Int16
            }
        }
        
        // Write a padding byte if necessary
        if self.size % 2 != 0 {
            result.append(0x00)
        }
        
        return result
    }
}
