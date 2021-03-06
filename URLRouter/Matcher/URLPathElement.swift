//
//  URLPathElement.swift
//  URLRouter
//
//  Created by Michael on 2019/9/9.
//

public enum URLPathElement {
    case scheme(String)
    case path(String)
    case placeholder(String)
}

extension URLPathElement: RawRepresentable {
    
    public typealias RawValue = String
    
    public static var root: URLPathElement { .path("") }
    
    public var pathElement: String {
        switch self {
        case .path(let element):
            return element
        case .placeholder(let element):
            return element
        case .scheme(let element):
            return element
        }
    }
    
    public var rawValue: RawValue {
        switch self {
        case .scheme(let component):
            return "\(component.lowercased())://"
        case .path(let component):
            return component.lowercased()
        case .placeholder(let component):
            return "<\(component.lowercased())>"
        }
    }
    
    public init(rawValue: RawValue) {
        if rawValue.hasSuffix("://") {
            let endIndex = rawValue.index(rawValue.endIndex, offsetBy: -3)
            let scheme = String(rawValue[..<endIndex])
            self = .scheme(scheme)
        } else if (rawValue.hasPrefix("<") && rawValue.hasSuffix(">")) {
            let start = rawValue.index(rawValue.startIndex, offsetBy: 1)
            let end = rawValue.index(rawValue.endIndex, offsetBy: -1)
            let placeHolder = String(rawValue[start..<end])
            self = .placeholder(placeHolder)
        } else {
            self = .path(rawValue)
        }
    }
}

extension URLPathElement: Equatable {
    public static func == (lhs: URLPathElement, rhs: URLPathElement) -> Bool {
        switch (lhs, rhs) {
        case let (.scheme(leftValue), .scheme(rightValue)):
            return leftValue.lowercased() == rightValue.lowercased()
        case let (.path(leftValue), .path(rightValue)):
            return leftValue.lowercased() == rightValue.lowercased()
        case let (.placeholder(leftValue), .placeholder(rightValue)):
            return leftValue.lowercased() == rightValue.lowercased()
        default:
            return false
        }
    }
}

extension URLPathElement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
