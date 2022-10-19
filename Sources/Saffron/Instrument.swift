import Foundation

public struct sfInst {
    var achInstName: String  // array 20 of char
    var wInstBagNdx: Word  // index to the instrument’s zone list in the IBAG sub-chunk
}

public struct sfInstBag {
    var wInstGenNdx: Word
    var wInstModNdx: Word
}

public struct sfModList {
    var sfModSrcOper: SFModulator
    var sfModDestOper: SFGenerator
    var modAmount: Short
    var sfModAmtSrcOper: SFModulator
    var sfModTransOper: SFTransform
}

public struct sfInstGenList {
    var sfGenOper: SFGenerator
    var genAmount: GeneratorAmount
}

public class InstrumentDefinition {
    var name: String  // array 20 of char
    var zones: [Zone]
    var globalZone: Zone?
    
    public init(name: String) {
        self.name = name
        self.zones = [Zone]()
    }
    
    public init(name: String, zones: [Zone], globalZone: Zone) {
        self.name = name
        self.zones = zones
        self.globalZone = globalZone
    }
    
    public func addZone(zone: Zone) {
        
    }
    
    public func removeZone(zone: Zone) {
        
    }
    
    public func clearZones() {
        
    }
    
    public var hasGlobalZone: Bool {
        return true
    }
}

// INST subchunk, see Section 7.6
// Always a multiple of twenty-two bytes in length, and contains
// a minimum of two records, one record for each instrument and
// one for a terminal record.
public class Instrument {
    var instruments: [sfInst]

    init(instruments: [sfInst]) {
        self.instruments = instruments
    }
}

extension Instrument: Chunk {
    public var name: String {
        get {
            return "INST"
        }
    }

    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

// IBAG subchunk, see Section 7.7
// A required sub-chunk listing all instrument zones.
// It is always a multiple of four bytes in length,
// and contains one record for each instrument zone
// plus one record for a terminal zone.
public class InstrumentBag {
    var zones: [sfInstBag]
    
    init(zones: [sfInstBag]) {
        self.zones = zones
    }
}

extension InstrumentBag: Chunk {
    public var name: String {
        get {
            return "IBAG"
        }
    }

    public var size: DWord {
        return 0
    }
    
    public var data: ByteArray {
        return ByteArray()
    }
}

// The IMOD such-chunk, Section 7.8
// A required sub-chunk listing all instrument zone modulators
// It is always a multiple of ten bytes in length, and contains
// zero or more modulators plus a terminal record.
public class InstrumentModulators {
    let itemSize = 10
    
    var modulators: [sfModList]
    
    public init(modulators: [sfModList]) {
        self.modulators = modulators
    }
    
    public var itemCount: Word {
        var modulatorCount = 1 // 1 = terminator
        
        for modulator in self.modulators {
            // Count the modulators in the global zone.
            if modulator.hasGlobalZone {
                modulatorCount += modulator.globalZone.modulators.count
            }

            // Count the modulators in the instrument zones.
            for zone in modulator.zones {
                modulatorCount += zone.modulators.count
            }
        }
        
        return Word(modulatorCount)
    }
}

extension InstrumentModulators: Chunk {
    public var name: String {
        get {
            return "IMOD"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.itemCount))
    }

    public var data: ByteArray {
        return ByteArray()
    }
}

// IGEN chunk, see Section 7.9
// The IGEN chunk is a required chunk containing a list of zone generators for each
// instrument zone within the SoundFont compatible file. It is always a multiple of four
// bytes in length, and contains one or more generators for each zone (except for a global
// zone containing only modulators) plus a terminal record.
public class InstrumentGenerator {
    let itemSize = 4  // the item size of "igen" chunk in bytes

    var generators: [sfInstGenList]
    
    public init(generators: [sfInstGenList]) {
        self.generators = generators
    }
    
    public var itemCount: Word {
        var generatorCount = 1 // 1 = terminator
        
        for generator in self.generators {
            // Count the generators in the global zone.
            if instrument.hasGlobalZone {
                generatorCount += instrument.globalZone.generators.size()
            }

            // Count the generators in the instrument zones.
            for zone in instrument.zones {
                numGenerators += (zone.hasSample ? 1 : 0) + zone.generators.size()
            }
        }
        return Word(generatorCount)
    }
}

extension InstrumentGenerator: Chunk {
    public var name: String {
        get {
            return "IGEN"
        }
    }
    
    public var size: DWord {
        return DWord(self.itemSize * Int(self.itemCount))
    }

    public var data: ByteArray {
        return ByteArray()
    }
}
