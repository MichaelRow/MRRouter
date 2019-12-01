//
//  GeneralURLMatcher.swift
//  URLRouter
//
//  Created by Michael on 2019/9/12.
//

public typealias URLMatchResult = (matchedNode: URLMapNode, placeholders: [String : String])

public protocol URLMatcher {
    
    func match(pattern: URLConvertible, with map: URLMapNode) -> URLMatchResult?
    
}

public struct GeneralURLMatcher: URLMatcher {
    
    public func match(pattern: URLConvertible, with map: URLMapNode) -> URLMatchResult? {
        guard let patternComponents = pattern.pathElement,
              let matchedResult = match(components: patternComponents, form: 0, with: map, placeholders: [:])
        else { return nil }
        
        return matchedResult
    }
    
    private func match(components: [URLPathElement], form startIndex: Int, with node: URLMapNode, placeholders: [String : String]) -> URLMatchResult? {
        guard startIndex < components.count else { return nil }
        let component = components[startIndex]
        
        if let childNode = node[component] {
            
            if startIndex < components.count - 1 {
                return match(components: components, form: startIndex + 1, with: childNode, placeholders: placeholders)
            } else {
                return (childNode, placeholders)
            }
        } else {
            
            for wildcardKey in node.placeholderKeys {
                guard let wildcardNode = node[wildcardKey] else { continue }
                let matchedResult: URLMatchResult?
                if startIndex < components.count - 1 {
                    matchedResult = match(components: components, form: startIndex + 1, with: wildcardNode, placeholders: placeholders)
                } else {
                    matchedResult = (wildcardNode, placeholders)
                }
                guard var result = matchedResult else { continue }
                result.placeholders[wildcardNode.nodePattern.pathElement] = component.pathElement
                return result
            }
        }
        return nil
    }
    
    public init() {}
}
