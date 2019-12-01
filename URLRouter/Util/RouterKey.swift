//
//  RouterKey.swift
//  Pods-URLRouter_Example
//
//  Created by Michael Row on 2019/10/5.
//

import Foundation

public extension Router {
    
    enum Option: String, CaseIterable {
        case withoutAnimation
        case useStackNavigation
        case wrapInNavigation
        case dismissModal
        case withoutDismissalAnimation
        case ignoreLevel
        case popReplaceAnimation
        case push
        case present
        
        var optionValue: RoutingOption {
            switch self {
            case .withoutAnimation:
                return .withoutAnimation
            case .useStackNavigation:
                return .useStackNavigation
            case .wrapInNavigation:
                return .wrapInNavigation
            case .dismissModal:
                return .dismissModal
            case .withoutDismissalAnimation:
                return .withoutDismissalAnimation
            case .ignoreLevel:
                return .ignoreLevel
            case .popReplaceAnimation:
                return .popReplaceAnimation
            case .push:
                return .push
            case .present:
                return .present
            }
        }
    }
    
}

public extension Dictionary where Key: ExpressibleByStringLiteral {
    
    subscript(key: Router.Option) -> Bool? {
        get {
            guard let strKey = key.rawValue as? Key,
                  let value = self[strKey]
            else { return nil }
            
            if let value = value as? Bool {
                return value
            } else if let value = value as? Int {
                return  value != 0
            } else if let value = value as? String {
                return Int(value) != 0
            }
            return nil
        }
        set {
            guard let strKey = key.rawValue as? Key else { return }
            self[strKey] = newValue as? Value
        }
    }
}
