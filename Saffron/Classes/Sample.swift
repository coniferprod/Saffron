import Foundation

public typealias SampleData = FixedSizeArray<Int16>

public class Sample {
    var name: String
    var data: SampleData
    var loopStart: DWord?
    var loopEnd: DWord?
    var sampleRate: DWord?
    var originalKey: Byte?
    var correction: Int?
    
    init(name: String, data: SampleData) {
        self.name = name
        self.data = data
        
    }
}
