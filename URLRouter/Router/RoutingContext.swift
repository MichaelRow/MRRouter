//
//  URLRoutingContext.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

public typealias RouterCompletion = (RouterError?) -> Void

@objc open class RoutingContext: NSObject {
    
    public private(set) var originalURL: URLConvertible
    
    public private(set) var originalParams: [String : Any]
    
    public private(set) var placeholders: [String : Any]
    
    public var params: [String : Any]
    
    public var viewControllerType: UIViewController.Type?
    
    public var completion: RouterCompletion?
    
    public lazy var option: RoutingOption = []
    
    public var toTabBarIndex: Int?
    
    public init(originalURL: URLConvertible, params: [String : Any]? = nil, placeholders: [String : Any]? = nil, viewControllerType: UIViewController.Type?, completion: RouterCompletion?) {
        self.originalURL = originalURL
        self.viewControllerType = viewControllerType
        self.completion = completion
        
        self.originalParams = params ?? [:]
        self.placeholders = placeholders ?? [:]
        self.params = self.placeholders
        self.params.merge(originalURL.queryParameters, uniquingKeysWith: { (_, new) in new })
        self.params.merge(self.originalParams, uniquingKeysWith: { (_, new) in new })
        self.params[.original] = self.originalParams
        self.params[.placeHolders] = self.placeholders
        self.params[.query] = originalURL.queryParameters
        
        super.init()
    }
}

public extension RoutingContext {
    subscript(key: Router.Params) -> [String : Any]? {
        get { return params[key] }
        set { params[key] = newValue }
    }
    
    subscript(key: Router.Option) -> Bool? {
        get { return params[key] }
        set { params[key] = newValue }
    }
}
