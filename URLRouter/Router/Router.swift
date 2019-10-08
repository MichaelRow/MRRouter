//
//  Router.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class Router {
    
    public static let shared = Router()
    
    public lazy var matcher: URLMatcher = GeneralURLMatcher()
    
    public var wildcardRouting: URLRouting?
    
    private(set) var rootNode = URLMapNode()
    
    public init() {}
    
    public func register(pattern: URLConvertible, viewControllerType: UIViewController.Type, routing: URLRouting? = nil, override: Bool = true) {
        guard let usedRouting = routing ?? wildcardRouting else {
            fatalError("必须在register方法中传入routing，或设置Router的wildcardRouting")
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
