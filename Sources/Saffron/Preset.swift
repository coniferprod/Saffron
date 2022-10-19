import Foundation

// PHDR sub-chunk, see section 7.2
public class PresetHeader {
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

extension PresetHeader: Chunk {
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
}

// PBAG sub-chunk, see section 7.3
public class PresetBag {
    let generatorIndex: Word
    let modulatorIndex: Word
    
    public init(generatorIndex: Word, modulatorIndex: Word) {
        self.generatorIndex = generatorIndex
        self.modulatorIndex = modulatorIndex
    }
}

extension PresetBag: Chunk {
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
}

public typealias SFModulator = Word
public typealias SFGenerator = Word
public typealias SFTransform = Word

public enum GeneratorAmount {
    case ranges(Ranges)
    case shortAmount(Short)
    case wordAmount(Word)
}

// PGEN subchunk, Section 7.5
public class GeneratorList {
    let genOper: SFGenerator
    let genAmount: GeneratorAmount
    
    public init(genOper: SFGenerator, genAmount: GeneratorAmount) {
        self.genOper = genOper
        self.genAmount = genAmount
    }
}

extension GeneratorList: Chunk {
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
}

public struct Preset {
    public var hasGlobalZone: Bool {
        return true
    }
    
}

public struct PresetZone {

}

