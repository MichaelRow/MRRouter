//
//  URLRoutingContext.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class URLRoutingContext {
    
    public private(set) var originalURL: URLConvertible
    
    public private(set) var originalParams: [String : Any]
    
    public private(set) var placeholders: [String : Any]
    
    public var params: [String : Any]
    
    public var viewControllerType: UIViewController.Type?
    
    public var completion: (() -> Void)?
    
    public lazy var option: RoutingOption = []
    
    public var toTabBarIndex: Int?
    
    public init(originalURL: URLConvertible, params: [String : Any]? = nil, placeholders: [String : Any]? = nil, viewControllerType: UIViewController.Type?, completion: (() -> Void)?) {
        self.originalURL = originalURL
        self.viewControllerType = viewControllerType
        self.completion = completion
        
        self.originalParams = params ?? [:]
        self.placeholders = placeholders ?? [:]
        self.params = self.placeholders
        self.params.merge(originalURL.queryParameters, uniquingKeysWith: { (_, new) in new })
        self.params.merge(self.originalParams, uniquingKeysWith: { (_, new) in new })
        self[.original] = self.originalParams
        self[.placeHolders] = self.placeholders
        self[.query] = originalURL.queryParameters
    }
    
    public func instantiateViewController() -> UIViewController? {
        if let viewController = viewControllerType?.routable?.init(params) as? UIViewController {
            return viewController
        } else {
            return viewControllerType?.init()
        }
    }
}

public extension URLRoutingContext {
    subscript(key: Router.Params) -> [String : Any]? {
        get { return params[key] }
        set { params[key] = newValue }
    }
    
    subscript(key: Router.Option) -> Bool? {
        get { return params[key] }
        set { params[key] = newValue }
    }
}
