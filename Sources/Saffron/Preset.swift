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

public typealias SFModulator = Word
public typealias SFGenerator = Word
public typealias SFTransform = Word

// PMOD sub-chunk, see section 7.4
public struct ModulatorList {
    let modSrcOper: SFModulator
    let modDestOper: SFGenerator
    let modAmount: Short
    let modAmtSrcOper: SFModulator
    let modTransOper: SFTransform
    
    public init(modSrcOper: SFModulator, modDestOper: SFGenerator, modAmount: Short, modAmtSrcOper: SFModulator, modTransOper: SFTransform) {
        self.modSrcOper = modSrcOper
        self.modDestOper = modDestOper
        self.modAmount = modAmount
        self.modAmtSrcOper = modAmtSrcOper
        self.modTransOper = modTransOper
    }
}

public struct Ranges {
    let low: Byte
    let high: Byte
    
    public init(low: Byte, high: Byte) {
        self.low = low
        self.high = high
    }
}

public enum GeneratorAmount {
    case ranges(Ranges)
    case shortAmount(Short)
    case wordAmount(Word)
}

// PGEN sub-chunk, see section 7.5
public struct GeneratorList {
    let genOper: SFGenerator
    let generatorAmount: GeneratorAmount
    
    public init(genOper: SFGenerator, generatorAmount: GeneratorAmount) {
        self.genOper = genOper
        self.generatorAmount = generatorAmount
    }
}

// Enumeration, see spec section 7.10 and 4.5
public enum SampleLink: Word {
    case monoSample = 1
    case rightSample = 2
    case leftSample = 4
    case linkedSample = 8
    case romMonoSample = 0x8001
    case romRightSample = 0x8002
    case romLeftSample = 0x8004
    case romLinkedSample = 0x8008
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

// IBAG sub-chunk, see section 7.7
public struct InstrumentBagSubChunk {
    let instGenIndex: Word
    let instModIndex: Word
    
    public init(instGenIndex: Word, instModIndex: Word) {
        self.instGenIndex = instGenIndex
        self.instModIndex = instModIndex
    }
}

// IMOD sub-chunk, see section 7.8
public struct InstrumentModulatorSubChunk {
    let modSrcOper: SFModulator
    let modDestOper: SFGenerator
    let modAmount: Short
    let modAmtSrcOper: SFModulator
    let modTransOper: SFTransform
    
    public init(modSrcOper: SFModulator, modDestOper: SFGenerator, modAmount: Short, modAmtSrcOper: SFModulator, modTransOper: SFTransform) {
        self.modSrcOper = modSrcOper
        self.modDestOper = modDestOper
        self.modAmount = modAmount
        self.modAmtSrcOper = modAmtSrcOper
        self.modTransOper = modTransOper
    }
}

// IGEN sub-chunk, see section 7.9
public struct InstrumentGeneratorList {
    let generatorOperator: Generator
    let generatorAmount: GeneratorAmount
    
    public init(generatorOperator: SFGenerator, generatorAmount: GeneratorAmount) {
        self.generatorOperator = generatorOperator
        self.generatorAmount = generatorAmount
    }
}

// SHDR sub-chunk, see section 7.10
public struct SampleHeaderSubChunk {
    let instrumentName: ByteArray  // 20 characters, filled up with zeros
    let start: DWord
    let end: DWord
    let startLoop: DWord
    let endLoop: DWord
    let sampleRate: DWord
    let originalPitch: Byte
    let pitchCorrection: Int8 // original user CHAR type, has both pos and neg values
    let sampleLink: Word
    let sampleType: SampleLink

    public init(instrumentName: ByteArray, start: DWord, end: DWord, startLoop: DWord, endLoop: DWord, sampleRate: DWord, originalPitch: Byte, pitchCorrection: Int8, sampleLink: Word, sampleType: SampleLinkType) {
        self.instrumentName = instrumentName
        self.start = start
        self.end = end
        self.startLoop = startLoop
        self.endLoop = endLoop
        self.sampleRate = sampleRate
        self.originalPitch = originalPitch
        self.pitchCorrection = pitchCorrection
        self.sampleLink = sampleLink
        self.sampleType = sampleType
    }
}

public struct Preset {
    public var hasGlobalZone: Bool {
        return true
    }
    
}

public struct PresetZone {

}

