//
//  Router.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

@dynamicMemberLookup
open class Router {
        
    public lazy var matcher: URLMatcher.Type = GeneralURLMatcher.self
    
    private(set) var rootNode = URLMapNode()
    
    public var navigator: Navigator
    
    public var wildcardRouting: URLRouting {
        didSet {
            wildcardRouting.nestRouter = self
        }
    }
    
    public init(_ navigator: Navigator, wildcardRouting: URLRouting = URLRouting.general()) {
        self.navigator = navigator
        self.wildcardRouting = wildcardRouting
        self.wildcardRouting.nestRouter = self
    }
    
    public func register(pattern: URLConvertible, viewControllerType: UIViewController.Type, routing: URLRouting? = nil, override: Bool = true) {
        var usedRouting = routing ?? wildcardRouting
        if usedRouting.nestRouter !== self {
            usedRouting.nestRouter = self
        }
        
        guard let patternComponents = pattern.pathElement else { return }
        var currentNode = rootNode
        patternComponents.enumerated().forEach { (offset: Int, component: URLPathElement) in
            if offset == patternComponents.count - 1 {
                currentNode.add(child: component, viewControllerType: viewControllerType, routing: usedRouting)
            } else {
                currentNode.add(child: component, override: false)
                currentNode = currentNode[component]!
            }
        }
    }
    
    public func unregister(pattern: URLConvertible, removeGrandchild: Bool = false) {
        guard let matchedResult = matcher.match(pattern: pattern, with: rootNode) else { return }
        matchedResult.matchedNode.parentNode?.remove(child: matchedResult.matchedNode.nodePattern, removeGrandchild: removeGrandchild)
    }
}

extension Router {
    subscript(dynamicMember keyPath: WritableKeyPath<Navigator,NavigatorDelegate?>) -> NavigatorDelegate? {
        get { navigator[keyPath: keyPath] }
        set { navigator[keyPath: keyPath] = newValue }
    }
}
