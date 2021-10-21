import Foundation

public struct GeneratorItem {
    
}

public struct ModulatorItem {
    
}

public class Zone {
    public var generators: [GeneratorItem]
    public var modulators: [ModulatorItem]
    
    public init(generators: [GeneratorItem], modulators: [ModulatorItem]) {
        self.generators = generators
        self.modulators = modulators
    }
    
}
