import Foundation

public typealias SampleData = [Int16]

public class Sample {
    // The length of terminator samples, in sample data points.
    public static let terminatorSampleLength = 46
    
    var name: String
    var start: DWord
    var end: DWord
    var startLoop: DWord
    var endLoop: DWord
    var sampleRate: DWord
    var byOriginalKey: Byte
    var correction: Char
    var sampleLink: Word
    var sampleType: SampleLink
    
    var data: SampleData

    init(name: String, data: SampleData) {
        self.name = name
        self.data = data
        
    }
}
