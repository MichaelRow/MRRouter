//
//  URLMapNode.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class URLMapNode {
    
    public var nodePattern: URLPathElement
    
    public var viewControllerType: UIViewController.Type?
    
    public var routing: URLRouting?
        
    public private(set) weak var parentNode: URLMapNode?
    
    public private(set) var childNodes = [URLPathElement : URLMapNode]()
    
    public private(set) var placeholderKeys = Set<URLPathElement>()
    
    public var fullPattern: URLConvertible {
        var parentNode = self.parentNode
        var allNode = [URLMapNode]()
        while let currentNode = parentNode {
            allNode.append(currentNode)
            parentNode = currentNode.parentNode
        }
        return allNode.reduce(""){ $0 + $1.nodePattern.rawValue + "/" }.normalizedURL
    }
    
    public init(pattern: URLPathElement = .path(""), viewControllerType: UIViewController.Type? = nil, routing: URLRouting? = nil) {
        self.nodePattern = pattern
        self.viewControllerType = viewControllerType
        self.routing = routing
    }
    
    public func add(child pattern: URLPathElement, viewControllerType: UIViewController.Type? = nil, routing: URLRouting? = nil, override: Bool = true) {
        if let node = self[pattern] {
            guard override else { return }
            node.viewControllerType = viewControllerType
            node.routing = routing
        } else {
            let node = URLMapNode(pattern: pattern, viewControllerType: viewControllerType, routing: routing)
            node.parentNode = self
            childNodes[pattern] = node
        }
        
        if case .placeholder(_) = pattern {
            placeholderKeys.insert(pattern)
        }
    }
    
    public func remove(child pattern: URLPathElement, removeGrandchild: Bool = true) {
        if let child = childNodes[pattern],
           child.childNodes.count > 0,
           !removeGrandchild
        {
            child.viewControllerType = nil
            child.routing = nil
        } else {
            childNodes.removeValue(forKey: pattern)
            placeholderKeys.remove(pattern)
            if childNodes.count == 0, viewControllerType == nil {
                parentNode?.remove(child: nodePattern)
            }
        }
    }
}

extension URLMapNode {
    
    subscript(key: URLPathElement) -> URLMapNode? {
        return childNodes[key]
    }
    
}
