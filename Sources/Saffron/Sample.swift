import Foundation

public typealias SampleData = [Short]

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

public class Sample {
    // The length of terminator samples, in sample data points.
    public static let terminatorSampleLength = 46
    
    var sampleName: String  // array of 20 characters
    var start: DWord
    var end: DWord
    var startLoop: DWord
    var endLoop: DWord
    var sampleRate: DWord
    var originalPitch: Byte
    var pitchCorrection: Char
    var sampleLink: Word
    var sampleType: SampleLink
    
    var data: SampleData

    init(name: String, data: SampleData) {
        self.sampleName = name
        self.data = data
        
        self.sampleName = ""
        self.start = 0
        self.end = 0
        self.startLoop = 0
        self.endLoop = 0
        self.sampleRate = 0
        self.originalPitch = 0
        self.pitchCorrection = 0x00
        self.sampleLink = 0
        self.sampleType = .leftSample
    }
}
