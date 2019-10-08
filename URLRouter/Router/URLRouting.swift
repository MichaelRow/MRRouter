//
//  URLRouting.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

public struct URLRouting {
    
    public private(set) var resolvers = [URLParameterHandler]()
    
    public private(set) var redirectors = [URLRedirectionHandler]()
    
    public private(set) var asyncHandlers = [URLParameterAsyncHandler]()
        
    public private(set) var navigator: Navigator
    
    public init(navigator: Navigator) {
        self.navigator = navigator
    }
    
    public mutating func add(resolver: URLParameterHandler) {
        resolvers.append(resolver)
        resolvers.sort { $0.priority > $1.priority }
    }
    
    public mutating func add(resolvers: [URLParameterHandler]) {
        self.resolvers.append(contentsOf: resolvers)
        self.resolvers.sort { $0.priority > $1.priority }
    }
    
    public mutating func add(redirector: URLRedirectionHandler) {
        redirectors.append(redirector)
        redirectors.sort { $0.priority > $1.priority }
    }
    
    public mutating func add(redirectors: [URLRedirectionHandler]) {
        self.redirectors.append(contentsOf: redirectors)
        self.redirectors.sort { $0.priority > $1.priority }
    }
    
    public mutating func add(asyncHandler: URLParameterAsyncHandler) {
        asyncHandlers.append(asyncHandler)
        asyncHandlers.sort { $0.priority > $1.priority }
    }
    
    public mutating func add(asyncHandlers: [URLParameterAsyncHandler]) {
        self.asyncHandlers.append(contentsOf: asyncHandlers)
        self.asyncHandlers.sort { $0.priority > $1.priority }
    }
}
