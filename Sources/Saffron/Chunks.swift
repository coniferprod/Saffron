import Foundation

public protocol Chunk {
    var name: String { get }  // chunk type identifier (converted to FourCC as necessary)
    var size: DWord { get } // chunk size field (size of data in bytes)
    var data: ByteArray { get }  // the actual data plus a pad byte if required to word align
    func write(out: OutputStream)
    func writeHeader(out: OutputStream, name: String, size: Int)
}

/// A chunk with sub-chunks.
public class ListChunk {
    public var subchunks: [Chunk]

    public init() {
        self.subchunks = [Chunk]()
    }
    
    public init(subchunks: [Chunk]) {
        self.subchunks = subchunks
    }
    
    public func addSubchunk(chunk: Chunk) {
        self.subchunks.append(chunk)
    }
    
    public func clearSubchunks() {
        self.subchunks.removeAll()
    }
}

extension ListChunk: Chunk {
    public var name: String {
        get {
            return "INFO"
        }
    }
    
    public var size: DWord {
        var sz = 0
        for subchunk in self.subchunks {
            sz += Int(subchunk.size)
        }
        return DWord(12 + sz)
    }

    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)
        for subchunk in self.subchunks {
            result.append(contentsOf: subchunk.data)
        }
        return result
    }
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size - 8))
        for subchunk in self.subchunks {
            subchunk.write(out: out)
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: Write the chunk ID "LIST"
        
        // TODO: Write the chunk size
        
        // TODO: Write the list type
    }
}

extension ListChunk: CustomStringConvertible {
    public var description: String {
        let chunkName = self.name
        var buf = "\(chunkName):\n"
        for chunk in subchunks {
            buf += "    \(chunk)\n"
        }
        return buf
    }
}

public class RIFF {
    var chunks: [Chunk]
    
    public init() {
        self.chunks = [Chunk]()
    }
    
    public func add(chunk: Chunk) {
        self.chunks.append(chunk)
    }
    
    public func clearChunks() {
        self.chunks.removeAll()
    }
}

extension RIFF: Chunk {
    public var name: String {
        get {
            return "RIFF"
        }
    }

    public var size: DWord {
        get {
            var sz = 0
            for chunk in self.chunks {
                sz += Int(chunk.size)
            }
        }
    }
    
    public var data: ByteArray {
        var result = ByteArray()
        let fourCC = self.name.toFourCC()
        result.append(contentsOf: fourCC.littleEndian.bytes)
        result.append(contentsOf: self.size.littleEndian.bytes)
        for chunk in self.chunks {
            result.append(contentsOf: chunk.data)
        }
        return result
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size - 8))
        for chunk in self.chunks {
            chunk.write(out: out)
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: Write the ID "RIFF"

        // TODO: Write the file size
        
        // TODO: Write the form type

    }
}

public class IfilSubchunk {
    let version: VersionTag
    
    public init(version: VersionTag) {
        self.version = version
    }
}

extension IfilSubchunk: Chunk {
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

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        let data = self.version.bytes
        // TODO: Write out the chunk data
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class INAMSubchunk {
    var bankName: String
    
    public init(bankName: String) {
        self.bankName = bankName
    }
}

extension INAMSubchunk: Chunk {
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
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        // TODO: Write out the chunk data
        let data = ZStr(value: self.bankName).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class ICRDSubchunk {
    var creationDate: String
    
    public init(creationDate: String) {
        self.creationDate = creationDate
    }
}

extension ICRDSubchunk: Chunk {
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
        return result
    }
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class INFOListChunk: ListChunk {
    override public init() {
        // Mandatory 'ifil' subchunk:
        self.addSubchunk(chunk: IfilSubchunk(version: VersionTag(major: 2, minor: 0)))

        // Optional 'isng' subchunk is ignored for now
        
        // INAM (mandatory)
        self.addSubchunk(chunk: INAMSubchunk(bankName: "General MIDI"))
        
        // No ROM samples, so ignore the IROM and iver subchunks
        
        // ICRD
        self.addSubchunk(chunk: ICRDSubchunk(creationDate: "April 10, 2021"))
        
        // Ignore IENG, IPRD, ICOP, ICMT, and ISFT subchunks for now.
    }
}

// The sdta-list chunk contains a single optional smpl sub-chunk
// which contains all the RAM based sound data.
public class SdtaListChunk: ListChunk {
    override public init() {
        self.addSubchunk(chunk: SmplSubchunk())
    }

    var samplePoolSize: DWord {
        get {
            return 0
            
            /*
             var size = 0
             for sample in self.samples {
                 size += UInt16.byteWidth * sample.data.count + Limits.terminatorSampleLength
                 if size > UInt32.max {
                     //throw SoundFontError.samplePoolOverflow
                     // TODO: handle the error
                 }
             }
             return DWord(size)
             */
        }
    }
}

// The smpl sub-chunk contains one or more samples in the form of
// linearly coded sixteen bit, signed, little endian (least significant byte first) words.
// Each sample is followed by a minimum of forty-six zero valued sample data points.
public class SmplSubchunk {
    var samples: [Sample]
    
    public init(samples: [Sample]) {
        self.samples = samples
    }
    
    var samplePoolSize: DWord {
        get {
            var size = 0
            for sample in self.samples {
                size += UInt16.byteWidth * sample.data.count + Limits.terminatorSampleLength
                if size > UInt32.max {
                    //throw SoundFontError.samplePoolOverflow
                    // TODO: handle the error
                }
            }
            return DWord(size)
        }
    }
}

extension SmplSubchunk: Chunk {
    public var name: String {
        get {
            return "smpl"
        }
    }
    
    public var size: DWord {
        return self.samplePoolSize
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

// The SHDR chunk is a required sub-chunk listing all samples within
// the smpl sub-chunk and any referenced ROM samples. It is always a
// multiple of forty-six bytes in length, and contains one record for
// each sample plus a terminal record according to the structure
public class SHDRSubchunk {
    var samples: [Sample]
    
    public init(samples: [Sample]) {
        self.samples = samples
    }
}

extension SHDRSubchunk: Chunk {
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
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}


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
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size - 8))
        
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
            // TODO: Write zero byte to `out`
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: Write the ID "RIFF"

        // TODO: Write the file size
        
        // TODO: Write the form type

    }
}

public class PdtaListChunk: ListChunk {
    var presets: [Preset]
    
    public override init() {
        self.presets = [Preset]()
    }
    
    public init(presets: [Preset]) {
        self.presets = presets
    }
}

public class PHDRSubchunk {
    var presetHeader: PresetHeader
    
    public init(presetHeader: PresetHeader) {
        self.presetHeader = presetHeader
    }
}

extension PHDRSubchunk: Chunk {
    public var name: String {
        get {
            return "PHDR"
        }
    }
    
    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class PBAGSubchunk {
    var presetBag: PresetBag
    
    public init(presetBag: PresetBag) {
        self.presetBag = presetBag
    }
}

extension PBAGSubchunk: Chunk {
    public var name: String {
        get {
            return "PBAG"
        }
    }
    
    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class PMODSubchunk {
    var modList: ModList
    
    public init(modList: ModList) {
        self.modList = modList
    }
}

extension PMODSubchunk: Chunk {
    public var name: String {
        get {
            return "PMOD"
        }
    }
    
    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class PGENSubchunk {
    var genList: GenList
    
    public init(genList: GenList) {
        self.genList = genList
    }
}

extension PGENSubchunk: Chunk {
    public var name: String {
        get {
            return "PGEN"
        }
    }
    
    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))

        /*
        // TODO: Write out the chunk data
        let data = ZStr(value: self.creationDate).bytes
        
        // Write a padding byte if necessary
        if data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
        */
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class INSTSubchunk {
    let itemSize = 22

    var instruments: [Instrument]
    
    public init(instruments: [Instrument]) {
        self.instruments = instruments
    }
    
    public var numItems: Word {
        var numItems = self.instruments.count + 1
        return Word(numItems)
    }
    
    public func writeItem(out: OutputStream, name: String, index: Word) {
        // TODO: Write instrument name
        // TODO: Write instrument bag index
    }
}

extension INSTSubchunk: Chunk {
    public var name: String {
        get {
            return "INST"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
    }

    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
        var index = 0
        for instrument in self.instruments {
            self.writeItem(out: out, name: instrument.name, index: Word(index))
        }
        
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class IBAGSubchunk {
    let itemSize = 4  // the item size of "ibag" chunk in bytes
    
    public var instruments: [Instrument]
    
    public init() {
        self.instruments = [Instrument]()
    }
    
    public init(instruments: [Instrument]) {
        self.instruments = instruments
    }
    
    public func writeItem(out: OutputStream, generatorIndex: Word, modulatorIndex: Word) {
        // TODO: Write generator index
        // TODO: Write modulator index
    }
    
    public var numItems: Word {
        var numZones = 1  // 1 = terminator
        for instrument in self.instruments {
            // Count the global zone
            if instrument.hasGlobalZone {
                numZones += 1
            }
            
            // Count the instrument zones
            numZones += instrument.zones.count
        }
        return Word(numZones)
    }
}

extension IBAGSubchunk: Chunk {
    public var name: String {
        get {
            return "IBAG"
        }
    }
    
    public var size: DWord {
        return DWord(itemSize * self.instruments.count)
    }

    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
        // Instruments:
        var generatorIndex = 0
        var modulatorIndex = 0
        for instrument in self.instruments {
            if instrument.hasGlobalZone {
                // Write the global zone
                self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
                
                generatorIndex += instrument.globalZone.generators.count
                modulatorIndex += instrument.globalZone.modulators.count
            }

            // Instrument zones:
            for zone in instrument.zones {
                self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
                
                generatorIndex += (zone.hasSample ? 1 : 0) + zone.generators.count
                modulatorIndex += zone.modulators.count
            }
        }
        
        // Write out the last terminator item
        self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
        
        // Write a padding byte if necessary
        if self.size % 2 != 0 {
            // TODO: Write a zero byte
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class IMODSubchunk {
    let itemSize = 10
    
    var instruments: [Instrument]
    
    public init(instruments: [Instrument]) {
        self.instruments = instruments
    }
    
    public var numItems: Word {
        var numModulators = 1 // 1 = terminator
        for instrument in self.instruments {
            // Count the modulators in the global zone.
            if instrument.hasGlobalZone {
                numModulators += instrument.globalZone.modulators.count
            }

            // Count the modulators in the instrument zones.
            for zone in instrument.zones {
                numModulators += zone.modulators.count
            }
        }
        return Word(numModulators)
    }
}

extension IMODSubchunk: Chunk {
    public var name: String {
        get {
            return "IMOD"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
    }

    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class IGENSubchunk {
    let itemSize = 4  // the item size of "igen" chunk in bytes

    var instruments: [Instrument]
    
    public init(instruments: [Instrument], sampleIndexMap: [Sample : Word]) {
        self.instruments = instruments
    }
    
    public var numItems: Word {
        var numGenerators = 1 // 1 = terminator
        for instrument in self.instruments {
            // Count the generators in the global zone.
            if instrument.hasGlobalZone {
                numGenerators += instrument.globalZone.generators.size()
            }

            // Count the generators in the instrument zones.
            for zone in instrument.zones {
                numGenerators += (zone.hasSample ? 1 : 0) + zone.generators.size()
            }
        }
        return Word(numGenerators)
    }
}

extension IGENSubchunk: Chunk {
    public var name: String {
        get {
            return "IGEN"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
    }

    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class SFBKForm {
    var infoList: INFOListChunk
    var sampleData: SdtaListChunk
    var presetData: PdtaListChunk
    
    public init() {
        
    }
}

extension SFBKForm: Chunk {
    public var name: String {
        get {
            return "RIFF"
        }
    }
    
    public var size: DWord {
        return self.infoList.size + self.sampleData.size + self.presetData.size
    }

    public var data: ByteArray {
        return ByteArray()
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size - 8))
        
        // Write a padding byte if necessary
        if self.size % 2 != 0 {
            // TODO: Write zero byte to `out`
        }
        
        self.infoList.write(out: out)
        self.sampleData.write(out: out)
        self.presetData.write(out: out)
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        
        // TODO: Write the ID "RIFF"

        // TODO: Write the file size
        
        // TODO: Write the form type

    }
}
