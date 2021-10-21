import Foundation

public typealias SampleData = [Int16]

public class Sample: Hashable {
    // The length of terminator samples, in sample data points.
    public static let terminatorSampleLength = 46
    
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
