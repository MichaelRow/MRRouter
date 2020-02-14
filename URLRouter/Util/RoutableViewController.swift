//
//  RoutableViewController.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/15.
//

import Foundation

@objc public enum StackLevel: Int {
    case lowest
    case utraLow
    case low
    case medium
    case high
    case utraHigh
    case highest
}

extension StackLevel: Equatable, Comparable {
    public static func < (lhs: StackLevel, rhs: StackLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

@objc public protocol RoutableViewController: class {
    
    @objc static var stackLevel: StackLevel { get }
    
    @objc var parameters: [String : Any] { get set }
}
