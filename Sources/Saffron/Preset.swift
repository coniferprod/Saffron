import Foundation

// PHDR sub-chunk, see section 7.2
public class PresetHeaderChunk {
    let presetName: ByteArray  // 20 characters, filled up with zeros
    let preset: Word
    let bank: Word
    let presetBagIndex: Word
    let library: DWord
    let genre: DWord
    let morphology: DWord
    
    public init(presetName: ByteArray, preset: Word, bank: Word, presetBagIndex: Word, library: DWord, genre: DWord, morphology: DWord) {
        self.presetName = presetName
        self.preset = preset
        self.bank = bank
        self.presetBagIndex = presetBagIndex
        self.library = library
        self.genre = genre
        self.morphology = morphology
    }
}

extension PresetHeaderChunk: Chunk {
    public var name: String {
        return "PHDR"
    }

    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

// PBAG sub-chunk, see section 7.3
public class PresetBagChunk {
    let generatorIndex: Word
    let modulatorIndex: Word
    
    public init(generatorIndex: Word, modulatorIndex: Word) {
        self.generatorIndex = generatorIndex
        self.modulatorIndex = modulatorIndex
    }
}

extension PresetBagChunk: Chunk {
    public var name: String {
        return "PBAG"
    }

    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

public typealias Modulator = Word
public typealias Generator = Word
public typealias Transform = Word

public enum GeneratorAmount {
    case ranges(Ranges)
    case shortAmount(Short)
    case wordAmount(Word)
}

// PGEN subchunk, Section 7.5
public class GeneratorListChunk {
    let genOper: Generator
    let genAmount: GeneratorAmount
    
    public init(genOper: Generator, genAmount: GeneratorAmount) {
        self.genOper = genOper
        self.genAmount = genAmount
    }
}

extension GeneratorListChunk: Chunk {
    public var name: String {
        return "PGEN"
    }

    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

public struct Preset {
    public var hasGlobalZone: Bool {
        return true
    }
    
}

public struct PresetZone {

}

