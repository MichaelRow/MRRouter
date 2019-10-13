//
//  Router.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

@dynamicMemberLookup
open class Router {
        
    public static let shared = Router()
    
    public lazy var matcher: URLMatcher = GeneralURLMatcher()
    
    public lazy var navigator: Navigator = GeneralNaigator()
    
    public internal(set) var rootNode = URLMapNode()
    
    public internal(set) var businessInstantiators = [String : () -> Any]()
    
    public internal(set) var businessSingletons = [String : Any]()
        
    public var wildcardRouting: URLRouting {
        didSet {
            wildcardRouting.nestRouter = self
        }
    }
    
    public init(_ wildcardRouting: URLRouting = URLRouting.general()) {
        self.wildcardRouting = wildcardRouting
        self.wildcardRouting.nestRouter = self
    }
}

public extension Router {
    
    subscript(dynamicMember keyPath: WritableKeyPath<Navigator,NavigatorDelegate?>) -> NavigatorDelegate? {
        get { navigator[keyPath: keyPath] }
        set { navigator[keyPath: keyPath] = newValue }
    }
    
    subscript(dynamicMember keyPath: WritableKeyPath<Navigator,UIWindow?>) -> UIWindow? {
        get { navigator[keyPath: keyPath] }
        set { navigator[keyPath: keyPath] = newValue }
    }
    
    subscript(dynamicMember keyPath: WritableKeyPath<Navigator,UINavigationController.Type>) -> UINavigationController.Type {
        get { navigator[keyPath: keyPath] }
        set { navigator[keyPath: keyPath] = newValue }
    }
}
