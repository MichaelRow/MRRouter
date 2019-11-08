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
    
    /// 注册路由
    /// - Parameter pattern: URL地址
    /// - Parameter viewControllerType: 符合RoutableViewController的VC
    /// - Parameter routing: URL参数解析与重定向路径
    /// - Parameter tabBarIndex: 需要打开的tabBar位置
    /// - Parameter override: 是否覆盖
    func register(pattern: URLConvertible, viewControllerType: (UIViewController & RoutableViewController).Type, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
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
    
    /// 注销注册表中的URL
    /// - Parameter removeGrandchild: 是否移除该节点之后的所有子节点
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
    
    /// 根据指定的URL初始化在注册表中的VC
    /// - Parameter url: URL
    /// - Parameter params: 初始化参数
    func instantiatedViewController(for url: URLConvertible, params: [String : Any]? = nil) -> UIViewController? {
        guard let type = matcher.match(pattern: url, with: rootNode)?.matchedNode.viewControllerType else { return nil }
        let viewController = type.init()
        if let params = params {
            viewController.routable?.parameters = params
        }
        return viewController
    }
    
    func back(_ useTopMost: Bool = true, animated: Bool = true) {
        navigator.back(useTopMost, animated: animated)
    }
    
    func dismiss(animated: Bool = true, completion: RouterCompletion? = nil) {
        navigator.dismiss(animated: animated, completion: completion)
    }
    
    func dismissLast(animated: Bool = true, completion: RouterCompletion? = nil) {
        navigator.dismiss(animated: animated, completion: completion)
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
