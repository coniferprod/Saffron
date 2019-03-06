import Foundation

public enum FixedSizeArrayError: Error {
    case outOfBounds(index: Int)
}

// Based on https://github.com/raywenderlich/swift-algorithm-club/tree/master/Fixed%20Size%20Array
public struct FixedSizeArray<T> {
    private var maxSize: Int
    private var array: [T]
    
    public init(maxSize: Int, initialValue: T) {
        self.maxSize = maxSize
        self.array = [T](repeating: initialValue, count: maxSize)
    }
    
    public var size: Int {
        get {
            return maxSize
        }
    }
    
    // Since subscript functions can't throw exceptions, the original
    // subscript asserted if the index was out of bounds. Asserts are ignored
    // in release builds, so the subscript has been replaced with a throwing function.
    public func get(index: Int) throws -> T {
        if (0..<maxSize).contains(index) {
            return self.array[index]
        }
        throw FixedSizeArrayError.outOfBounds(index: index)
    }
    
    public mutating func set(index: Int, _ newValue: T) throws {
        if (0..<maxSize).contains(index) {
            self.array[index] = newValue
        }
        else {
            throw FixedSizeArrayError.outOfBounds(index: index)
        }
    }
    
    public mutating func reset(newValue: T) {
        self.array = [T](repeating: newValue, count: maxSize)
    }
}
