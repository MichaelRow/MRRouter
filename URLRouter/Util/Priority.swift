//
//  Priority.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/8.
//

public typealias StackLevel = Priority

public enum Priority {
    case lowest
    case low
    case medium
    case high
    case highest
    case custom(priority: RawValue)
}

extension Priority: RawRepresentable {
    
    public typealias RawValue = UInt
    
    public init(rawValue: RawValue) {
        switch rawValue {
        case ...1:
            self = .lowest
        case 250:
            self = .low
        case 500:
            self = .medium
        case 750:
            self = .high
        case 1000...:
            self = .highest
        default:
            self = .custom(priority: rawValue)
        }
    }
    
    public var rawValue: RawValue {
        switch self {
        case .lowest:
            return 1
        case .low:
            return 250
        case .medium:
            return 500
        case .high:
            return 750
        case .highest:
            return 1000
        case .custom(let priority):
            var fixedPriority = min(Priority.highest.rawValue, priority)
            fixedPriority = max(Priority.lowest.rawValue, fixedPriority)
            return fixedPriority
        }
    }
    
    public mutating func normalize() {
        self = Priority(rawValue: self.rawValue)
    }
}

extension Priority: Comparable {
    
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
