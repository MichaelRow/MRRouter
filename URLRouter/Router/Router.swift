//
//  Router.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class Router {
        
    public lazy var matcher: URLMatcher.Type = GeneralURLMatcher.self
    
    private(set) var rootNode = URLMapNode()
    
    public var wildcardRouting: URLRouting? {
        didSet {
            wildcardRouting?.router = self
        }
    }
    
    public init(_ wildcardRouting: URLRouting? = nil) {
        self.wildcardRouting = wildcardRouting
        self.wildcardRouting?.router = self
    }
    
    public func register(pattern: URLConvertible, viewControllerType: UIViewController.Type, routing: URLRouting? = nil, override: Bool = true) {
        guard var usedRouting = routing ?? wildcardRouting else {
            fatalError("必须在register方法中传入routing，或设置Router的wildcardRouting")
        }
        if usedRouting.router !== self {
            usedRouting.router = self
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
