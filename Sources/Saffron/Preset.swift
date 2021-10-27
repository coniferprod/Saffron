import Foundation

// PHDR sub-chunk, see section 7.2
public struct PresetHeader {
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

// PBAG sub-chunk, see section 7.3
public struct PresetBag {
    let generatorIndex: Word
    let modulatorIndex: Word
    
    public init(generatorIndex: Word, modulatorIndex: Word) {
        self.generatorIndex = generatorIndex
        self.modulatorIndex = modulatorIndex
    }
}

public typealias Modulator = Word
public typealias Generator = Word
public typealias Transform = Word

public struct ModList {
    let modSrcOper: Modulator
    let modDestOper: Generator
    let modAmount: Short
    let modAmtSrcOper: Modulator
    let modTransOper: Transform
    
    public init(modSrcOper: Modulator, modDestOper: Generator, modAmount: Short, modAmtSrcOper: Modulator, modTransOper: Transform) {
        self.modSrcOper = modSrcOper
        self.modDestOper = modDestOper
        self.modAmount = modAmount
        self.modAmtSrcOper = modAmtSrcOper
        self.modTransOper = modTransOper
    }
}

public enum GenAmount {
    case ranges(Ranges)
    case shortAmount(Short)
    case wordAmount(Word)
}

public struct GenList {
    let genOper: Generator
    let genAmount: GenAmount
    
    public init(genOper: Generator, genAmount: GenAmount) {
        self.genOper = genOper
        self.genAmount = genAmount
    }
}

// INST sub-chunk, see section 7.6
public struct InstrumentSubChunk {
    let instrumentName: ByteArray  // 20 characters, filled up with zeros
    let instrumentBagIndex: Word
    
    public init(instrumentName: ByteArray, instrumentBagIndex: Word) {
        self.instrumentName = instrumentName
        self.instrumentBagIndex = instrumentBagIndex
    }
}

public struct Preset {
    public var hasGlobalZone: Bool {
        return true
    }
    
}

public struct PresetZone {

}

