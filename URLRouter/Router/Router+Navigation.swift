//
//  Router+Navigator.swift
//  URLRouter
//
//  Created by Michael on 2019/9/12.
//

import UIKit

public enum TabBarOpenType {
    ///使用当前的tab打开
    case current
    ///使用预设的tab打开
    case preset
    ///使用自定义tab打开
    case custom(Int)
}

public extension Router {
    
    func register(pattern: URLConvertible, viewControllerType: UIViewController.Type, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
        var usedRouting = routing ?? wildcardRouting
        if usedRouting.nestRouter !== self {
            usedRouting.nestRouter = self
        }
        
        guard let patternComponents = pattern.pathElement else { return }
        var currentNode = rootNode
        patternComponents.enumerated().forEach { (offset: Int, component: URLPathElement) in
            if offset == patternComponents.count - 1 {
                currentNode.add(child: component, viewControllerType: viewControllerType, routing: usedRouting, tabBarIndex: tabBarIndex, override: override)
            } else {
                currentNode.add(child: component, override: false)
                currentNode = currentNode[component]!
            }
        }
    }
    
    func unregister(pattern: URLConvertible, removeGrandchild: Bool = false) {
        guard let matchedResult = matcher.match(pattern: pattern, with: rootNode) else { return }
        matchedResult.matchedNode.parentNode?.remove(child: matchedResult.matchedNode.nodePattern, removeGrandchild: removeGrandchild)
    }
    
    /// 是否有注册当前URL
    func canOpen(url: URLConvertible) -> Bool {
        return matcher.match(pattern: url, with: rootNode)?.matchedNode.routing != nil
    }
    
    /// 获得注册在Router中的VC类型
    func registeredViewController(for url: URLConvertible) -> UIViewController.Type? {
        return matcher.match(pattern: url, with: rootNode)?.matchedNode.viewControllerType
    }
    
    func push(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.push).subtracting(.present)
        open(url: url, parameters: parameters, option: opt, tabBarOpenType: tabBarOpenType, completion: completion)
    }
    
    func present(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.present).subtracting(.push)
        open(url: url, parameters: parameters, option: opt, tabBarOpenType: tabBarOpenType, completion: completion)
    }
    
    func open(url: URLConvertible, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let result = matcher.match(pattern: url, with: rootNode)
        
        let context = RoutingContext(originalURL: url, params: parameters, placeholders: result?.placeholders, viewControllerType: result?.matchedNode.viewControllerType, completion: completion)
        context.option = option
        
        switch tabBarOpenType {
        case .current:
            context.toTabBarIndex = nil
        case .preset:
            context.toTabBarIndex = result?.matchedNode.tabBarIndex
        case .custom(let index):
            context.toTabBarIndex = index
        }
        
        if let routing = result?.matchedNode.routing {
            routing.handle(context) { context, error in
                if let error = error {
                    completion?(error)
                } else {
                    navigator.open(context: context)
                }
            }
        } else {
            completion?(.noRouting)
        }
    }
}
