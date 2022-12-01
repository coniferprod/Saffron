import Foundation

enum Subchunk {
    case ifil(VersionTag)
    case isng(String)
    case INAM(String)
    case irom(String)
    case iver(VersionTag)
    case ICRD(String)
    case IENG(String)
    case IPRD(String)
    case ICOP(String)
    case ICMT(String)
    case ISFT(String)
}

public struct VersionTag {
    let major: Word
    let minor: Word
    
    public init(major: Word, minor: Word) {
        self.major = major
        self.minor = minor
    }
    
    public var bytesLE: ByteArray {
        var result = ByteArray()
        result.append(contentsOf: self.major.bytesLE)
        result.append(contentsOf: self.minor.bytesLE)
        return result
    }
}

public class VersionChunk {
    public let version: VersionTag

    public init(version: VersionTag) {
        self.version = version
    }
}

extension VersionChunk: Chunk {
    public var name: String {
        return "ifil"
    }
    
    public var size: DWord {
        return DWord(self.version.bytesLE.count)
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.bytesBE)
        result.append(contentsOf: self.size.bytesLE)
        result.append(contentsOf: self.version.bytesLE)
        return result
    }
}

public func getSamplePoolSize(samples: [Sample]) -> DWord {
    let wordByteWidth = 2  // the width of UInt16 in bytes
    
    var size = 0
    for sample in samples {
        size += wordByteWidth * sample.data.count + Limits.terminatorSampleLength
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
public class SampleHeaderChunk {
    var samples: [Sample]
    
    public init(samples: [Sample]) {
        self.samples = samples
    }
}

extension SampleHeaderChunk: Chunk {
    public var name: String {
        return "SHDR"
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
        let wordByteWidth = 2  // the width of UInt16 in bytes

        var size = 0
        for sample in self.samples {
            size += wordByteWidth * (sample.data.count + Sample.terminatorSampleLength)
        }
        return size
    }
}

extension SampleChunk: Chunk {
    public var name: String {
        return "smpl"
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
