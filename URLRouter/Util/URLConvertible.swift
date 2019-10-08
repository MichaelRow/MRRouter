//
//  URLConvertible.swift
//  URLRouter
//
//  Created by Michael on 2019/9/12.
//

import Foundation

public protocol URLConvertible {
    
    static var storedRegexs: [RegexReplaceHandler]? { get set }
    var urlValue: URL? { get }
    var urlStringValue: String { get }
    var queryParameters: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var normalizedURL: URLConvertible { get }
    var pathElement: [URLPathElement]? { get }
}

extension URLConvertible {
    
    public var queryParameters: [String: String] {
        var parameters = [String: String]()
        self.urlValue?.query?.components(separatedBy: "&").forEach { component in
            guard let separatorIndex = component.firstIndex(of: "=") else { return }
            let keyRange = component.startIndex..<separatorIndex
            let valueRange = component.index(after: separatorIndex)..<component.endIndex
            let key = String(component[keyRange])
            let value = component[valueRange].removingPercentEncoding ?? String(component[valueRange])
            parameters[key] = value
        }
        return parameters
    }
    
    public var queryItems: [URLQueryItem]? {
        guard let absoluteString = self.urlValue?.absoluteString else { return nil }
        return URLComponents(string: absoluteString)?.queryItems
    }
    
    public var pathElement: [URLPathElement]? {
        guard let prettyURL = normalizedURL.urlValue else { return nil }
        var components = [URLPathElement]()
        if let scheme = prettyURL.scheme {
            components.append(.scheme(scheme))
        }
        if let host = prettyURL.host {
            components.append(.path(host))
        }
        let restComponents = prettyURL.pathComponents.filter{ $0 != "/" }.map{ URLPathElement(rawValue: $0) }
        components.append(contentsOf: restComponents)
        return components
    }
}

extension URLConvertible {
    
    public var normalizedURL: URLConvertible {
        var prettyURL: URLConvertible = self
        Self.initilizeRegexIfNeeded()
        Self.storedRegexs?.forEach { handler in
            prettyURL = handler.replace(prettyURL)
        }
        return prettyURL
    }
    
    private static func initilizeRegexIfNeeded() {
        if storedRegexs == nil {
            storedRegexs = []
            appendRegex(":/{3,}", replacement:"://")
            appendRegex("(?<!:)/{2,}", replacement:"/")
            appendRegex("(?<!:|:/)/+$", replacement:"")
        }
    }
    
    private static func appendRegex(_ pattern: String, replacement: String) {
        if let regex = RegexReplaceHandler(pattern: pattern, replacement: replacement) {
            storedRegexs?.append(regex)
        }
    }
}

extension URL: URLConvertible {
    public static var storedRegexs: [RegexReplaceHandler]?
    public var urlValue: URL? { return self }
    public var urlStringValue: String { return self.absoluteString }
}

extension String: URLConvertible {
    public static var storedRegexs: [RegexReplaceHandler]?
    public var urlValue: URL? {
        if let url = URL(string: self) { return url }
        var set = CharacterSet()
        set.formUnion(.urlHostAllowed)
        set.formUnion(.urlPathAllowed)
        set.formUnion(.urlQueryAllowed)
        set.formUnion(.urlFragmentAllowed)
        return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
    }
    public var urlStringValue: String { return self }
}
