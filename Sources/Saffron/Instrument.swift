import Foundation

public struct Inst {
    var instName: String  // array 20 of char
    var instBagNdx: Word
}

public struct InstBag {
    var instGenNdx: Word
    var instModNdx: Word
}

public struct InstModList {
    var modSrcOper: Modulator
    var modDestOper: Generator
    var modAmount: Short
    var modAmtSrcOper: Modulator
    var modTransOper: Transform
}

public struct InstGenList {
    var genOper: Generator
    var genAmount: GenAmount
}

public class Instrument {
    var name: String  // array 20 of char
    var zones: [InstrumentZone]
    var globalZone: InstrumentZone?
    
    public init(name: String) {
        self.name = name
        self.zones = [InstrumentZone]()
    }
    
    public init(name: String, zones: [InstrumentZone], globalZone: InstrumentZone) {
        self.name = name
        self.zones = zones
        self.globalZone = globalZone
    }
    
    public func addZone(zone: InstrumentZone) {
        
    }
    
    public func removeZone(zone: InstrumentZone) {
        
    }
    
    public func clearZones() {
        
    }
    
    public var hasGlobalZone: Bool {
        return true
    }
}

public struct InstrumentZone {
    
}
