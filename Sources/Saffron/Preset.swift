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

//public typealias GenAmountType = Word  // this is actually a union type, see spec

// Use Swift enum as a discriminated union
public enum GenAmountType {
    case ranges(RangesType)
    case shortAmount(Short)
    case wordAmount(Word)
}

// PGEN sub-chunk, see section 7.5
public struct GeneratorList {
    let genOper: SFGenerator
    let genAmount: GenAmountType
    
    public init(genOper: SFGenerator, genAmount: GenAmountType) {
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
    let genOper: SFGenerator
    let genAmount: GenAmountType
    
    public init(genOper: SFGenerator, genAmount: GenAmountType) {
        self.genOper = genOper
        self.genAmount = genAmount
    }
}

public struct RangesType {
    let low: Byte
    let high: Byte
    
    public init(low: Byte, high: Byte) {
        self.low = low
        self.high = high
    }
}

// Enumeration, see spec section 7.10
public enum SampleLinkType: Word {
    case monoSample = 1
    case rightSample = 2
    case leftSample = 4
    case linkedSample = 8
    case romMonoSample = 32769
    case romRightSample = 32770
    case romLeftSample = 32772
    case romLinkedSample = 32776
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
    let sampleType: SampleLinkType

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

