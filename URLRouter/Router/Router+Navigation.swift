//
//  Router+Navigator.swift
//  URLRouter
//
//  Created by Michael on 2019/9/12.
//

import Foundation

public extension Router {
    
    func push(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabbarIndex: Int? = nil, completion:(() -> Void)? = nil) {
        let opt = option.union(.push).subtracting(.present)
        open(url: url, parameters: parameters, option: opt, tabbarIndex: tabbarIndex, completion: completion)
    }
    
    func present(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabbarIndex: Int? = nil, completion:(() -> Void)? = nil) {
        let opt = option.union(.present).subtracting(.push)
        open(url: url, parameters: parameters, option: opt, tabbarIndex: tabbarIndex, completion: completion)
    }
    
    func open(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabbarIndex: Int? = nil, completion:(() -> Void)? = nil) {
        let result = matcher.match(pattern: url, with: rootNode)
        
        let context = RoutingContext(originalURL: url, params: parameters, placeholders: result?.placeholders, viewControllerType: result?.matchedNode.viewControllerType, completion: completion)
        context.option = option
        context.toTabBarIndex = tabbarIndex
        
        if let routing = result?.matchedNode.routing {
            routing.handle(context)
        } else {
            completion?()
        }
    }
}
