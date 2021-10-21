import Foundation

public class Instrument {
    var name: String
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
