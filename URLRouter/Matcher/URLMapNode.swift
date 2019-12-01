//
//  URLMapNode.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class URLMapNode {
    
    public var nodePattern: URLPathElement
    
    public var storedVC: StoredVC?
    
    public var routing: URLRouting?
    
    public var tabBarIndex: Int?
        
    public private(set) weak var parentNode: URLMapNode?
    
    public private(set) var childNodes = [URLPathElement : URLMapNode]()
    
    public private(set) var placeholderKeys = Set<URLPathElement>()
    
    public var fullPattern: URLConvertible {
        var parentNode: URLMapNode? = self
        var allNode = [URLMapNode]()
        while let currentNode = parentNode, currentNode.nodePattern != .root {
            allNode.append(currentNode)
            parentNode = currentNode.parentNode
        }
        return allNode.reversed().reduce(""){ $0 + $1.nodePattern.rawValue + "/" }.normalizedURL
    }
    
    public init(pattern: URLPathElement = .root, storedVC: StoredVC? = nil, routing: URLRouting? = nil, tabBarIndex: Int? = nil) {
        self.nodePattern = pattern
        self.storedVC = storedVC
        self.routing = routing
        self.tabBarIndex = tabBarIndex
    }
    
    public func add(child pattern: URLPathElement, storedVC: StoredVC? = nil, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
        if let node = self[pattern] {
            let canOverride = override && storedVC != nil
            let isFirstWrite = !override && node.storedVC == nil
            guard canOverride || isFirstWrite else { return }
            
            node.storedVC = storedVC
            node.routing = routing
            node.tabBarIndex = tabBarIndex
        } else {
            let node = URLMapNode(pattern: pattern, storedVC: storedVC, routing: routing, tabBarIndex: tabBarIndex)
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
            child.storedVC = nil
            child.routing = nil
        } else {
            childNodes.removeValue(forKey: pattern)
            placeholderKeys.remove(pattern)
            if childNodes.count == 0, storedVC == nil {
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
