import Foundation

public protocol Chunk {
    var name: String { get }  // chunk type identifier (converted to FourCC as necessary)
    var size: DWord { get } // chunk size field (size of data in bytes)
    func write(out: OutputStream)
    func writeHeader(out: OutputStream, name: String, size: Int)
}

/// Represents a chunk in the RIFF protocol
public struct SimpleChunk {
    var _name: String
    var data: ByteArray
}

extension SimpleChunk: Chunk {
    public var name: String {
        get {
            return _name
        }
    }
    
    public var size: DWord {
        var sz = self.data.count
        if sz % 2 != 0 {
            sz += 1
        }
        return DWord(8 + sz)
    }
    
    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        // TODO: Write out the chunk data
        
        // Write a padding byte if necessary
        if self.data.count % 2 != 0 {
            // TODO: Write a zero byte to `out`
        }
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

/// A chunk with sub-chunks.
public struct ListChunk {
    var _name: String   // chunk name (will have to convert this to and from FourCC)
    var data: ByteArray

    public var subchunks: [Chunk]

    public init(name: String) {
        self._name = name
        self.subchunks = [Chunk]()
    }
    
    public init(name: String, subchunks: [Chunk]) {
        self._name = name
        self.subchunks = subchunks
    }
    
    public mutating func addSubchunk(chunk: Chunk) {
        self.subchunks.append(chunk)
    }
    
    public mutating func clearSubchunks() {
        self.subchunks.removeAll()
    }
}

extension ListChunk: Chunk {
    public var name: String {
        get {
            return _name
        }
    }
    
    public var size: DWord {
        var sz = 0
        for subchunk in self.subchunks {
            sz += Int(subchunk.size)
        }
        return DWord(12 + sz)
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
    var name: String
    var chunks: [Chunk]
    
    public init(name: String) {
        self.name = name
        self.chunks = [Chunk]()
    }
    
    public func add(chunk: Chunk) {
        self.chunks.append(chunk)
    }
    
    public func clearChunks() {
        self.chunks.removeAll()
    }
    
    public var size: DWord {
        get {
            var sz = 0
            for chunk in self.chunks {
                sz += Int(chunk.size)
            }
        }
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

public class IbagChunk {
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
            numZones += instrument.zones.size
        }
        return Word(numZones)
    }
}

extension IbagChunk: Chunk {
    public var name: String {
        get {
            return "ibag"
        }
    }
    
    public var size: DWord {
        return DWord(itemSize * self.instruments.count)
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
                
                generatorIndex += instrument.globalZone.generators.size
                modulatorIndex += instrument.globalZone.modulators.size
            }

            // Instrument zones:
            for zone in instrument.zones {
                self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
                
                generatorIndex += (zone.hasSample ? 1 : 0) + zone.generators.size
                modulatorIndex += zone.modulators.size
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

public class IgenChunk {
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

extension IgenChunk: Chunk {
    public var name: String {
        get {
            return "igen"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class ImodChunk {
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

extension ImodChunk: Chunk {
    public var name: String {
        get {
            return "imod"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
    }
    
    public func writeHeader(out: OutputStream, name: String, size: Int) {
        // TODO: write the chunk name
        // TODO: write the chunk size
    }
}

public class InstChunk {
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

extension InstChunk: Chunk {
    public var name: String {
        get {
            return "imod"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.numItems))
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

public class PbagChunk {
    let itemSize = 4

    var presets: [Preset]
    
    public init(presets: [Preset]) {
        self.presets = presets
    }

    public var numItems: Word {
        var numZones = 1 // 1 = terminator
        for preset in self.presets {
            // Count the global zone.
            if preset.hasGlobalZone {
                numZones += 1
            }

            // Count the preset zones.
            numZones += preset.zones.count
        }
        return Word(numZones)
    }
    
    public func writeItem(out: OutputStream, generatorIndex: Word, modulatorIndex: Word) {
        // TODO: Write generator index
        // TODO: Write modulator index
    }
}

extension PbagChunk: Chunk {
    public var name: String {
        get {
            return "pbag"
        }
    }
    
    public var size: DWord {
        return DWord(8 + self.itemSize * Int(self.numItems))
    }

    public func write(out: OutputStream) {
        self.writeHeader(out: out, name: self.name, size: Int(self.size))
        
        // Presets:
        var generatorIndex = 0
        var modulatorIndex = 0
        for preset in self.presets {
            if preset.hasGlobalZone {
                // Write the global zone
                self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
                
                generatorIndex += preset.globalZone.generators.count
                modulatorIndex += preset.globalZone.modulators.count
            }

            // Preset zones:
            for zone in preset.zones {
                self.writeItem(out: out, generatorIndex: Word(generatorIndex), modulatorIndex: Word(modulatorIndex))
                
                generatorIndex += (zone.hasInstrument ? 1 : 0) + zone.generators.size
                modulatorIndex += zone.modulators.size
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

public class InfoListChunk: ListChunk {
    let defaultEngine = "EMU8000"
    
    public init() {
        var chunks = [Chunk]()
        
        // Mandatory 'ifil' subchunk:
        let versionTag = VersionTag(major: 2, minor: 0)
        let data = versionTag.asData()
        let versionChunk = Chunk(name: "ifil", size: DWord(data.count), data: data)
        chunks.append(versionChunk)

        // Optional 'isng' subchunk is ignored for now
        
        // INAM (mandatory)
        var nameData = ChunkData()
        nameData.append(contentsOf: "General MIDI".utf8)
        chunks.append(Chunk(name: "INAM", size: 12, data: nameData))
        
        // No ROM samples, so ignore the IROM and iver subchunks
        
        var creationData = ChunkData()
        creationData.append(contentsOf: "April 10, 2021".utf8) // byte count is even
        chunks.append(Chunk(name: "ICRD", size: 14, data: creationData))
        
        // Ignore IENG, IPRD, ICOP, ICMT, and ISFT subchunks.
        
        super.init(name: "INFO", subchunks: chunks)
    }
}

enum SoundFontError: Error {
    case samplePoolOverflow
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

public class SampleDataListChunk: ListChunk {
    var samples: [Sample]
    
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
    
    public init() {
        self.samples = [Sample]()
    }
    
    public init(samples: [Sample]) {
        self.samples = samples

        var chunks = [Chunk]()
        for sample in self.samples {
            chunks.append(Chunk(name: "smpl", size: 0, data: ChunkData()))
        }
        
        super.init(name: "sdta", subchunks: chunks)
    }
}

public class PresetDataListChunk: ListChunk {
    public init() {
        super.init(name: "pdta")
        
    }
}

// Secion 4.1: SFBK-form
public class RIFFChunk {
    public var name: String
    public var sampleData: SampleDataListChunk
    public var presetData: PresetDataListChunk
    
    public init() {
        name = "sfbk"
        sampleData = SampleDataListChunk()
        presetData = PresetDataListChunk()
    }
}


public class PresetHeaderChunk: Chunk {
    var presetName: String
    var preset: Word
    var bank: Word
    var presetBagIndex: Word
    var library: DWord
    var genre: DWord
    var morphology: DWord
    
    let itemSize = 38  // the item size of "phdr" chunk
    
    var presets: [Preset]
    
    public init(presets: [Preset]) {
        self.presets = presets
        
        //super.init(name: "phdr", dataSize: Int(size))
        super.init(name: "phdr", dataSize: 0)

        // TODO: Prepare the chunk data
    }    
}

public class PresetBagChunk: Chunk {
    var genIndex: Word
    var modIndex: Word
    
    let itemSize = 4  // the item size of "pbag" chunk

}

public class HeaderSubChunk: Chunk {
    var maxSize: Int
    
    private var fieldValue: [Byte]
    
    var field: String {
        get {
            
            
        }
        
        set {
            
        }
    }
    
    
    public init(subChunkName: String, maxSize: Int = 0x100) {
        self.name = subChunkName
        
        self.maxSize = maxSize
    }
    
    public override var description: String {
        let chunkName = self.name
        var buf = "Header chunk: name=\(chunkName), maxSize=\(maxSize)"
        return buf
    }
}
    
    
public class Version: Chunk {
    private var version: VersionTag
    
    public init(version: VersionTag) {
        self.name = "iver"
        self.version = version
        
        // Prepare the chunk data from the version struct
        var versionData = ChunkData(maxSize: 4, initialValue: 0)
        
        do {
            try versionData.set(index: 0, Byte(version.major >> 8))
            try versionData.set(index: 1, UInt8(version.major & 0x00ff))
            
            try versionData.set(index: 2, Byte(version.minor >> 8))
            try versionData.set(index: 3, UInt8(version.minor & 0x00ff))
        }
        catch {
            print("Index out of bounds")
        }
                
    }
}
