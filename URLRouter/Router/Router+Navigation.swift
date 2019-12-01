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
    
    struct Name: RawRepresentable {
        
        public typealias RawValue = String
        
        public var rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public init(url: URLConvertible) {
            self.rawValue = url.urlStringValue
        }
    }
}

public extension Router {
    
    /// 注册路由
    /// - Parameter pattern: URL地址
    /// - Parameter viewControllerType: 符合RoutableViewController的VC
    /// - Parameter routing: URL参数解析与重定向路径
    /// - Parameter tabBarIndex: 需要打开的tabBar位置
    /// - Parameter override: 是否覆盖
    // TODO: - 暂时去掉限制, 因为旧工程OC存在问题 (todo xiaofengmin)

//    func register(pattern: Name, viewControllerType: (UIViewController & RoutableViewController).Type, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
    func register(pattern: Name, viewControllerType: UIViewController.Type, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
        var usedRouting = routing ?? wildcardRouting
        if usedRouting.nestRouter !== self {
            usedRouting.nestRouter = self
        }
        
        guard let patternComponents = pattern.rawValue.pathElement else { return }
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
    func unregister(pattern: Name, removeGrandchild: Bool = false) {
        guard let matchedResult = matcher.match(pattern: pattern.rawValue, with: rootNode) else { return }
        matchedResult.matchedNode.parentNode?.remove(child: matchedResult.matchedNode.nodePattern, removeGrandchild: removeGrandchild)
    }
    
    /// 是否有注册当前URL
    func canOpen(url: URLConvertible) -> Bool {
        return matcher.match(pattern: url, with: rootNode)?.matchedNode.routing != nil
    }
    
    /// 是否有注册当前URL
    func canOpen(pattern: Name) -> Bool {
        return canOpen(url: pattern.rawValue)
    }
    
    /// 获得注册在Router中的VC类型
    func registeredViewController(for pattern: Name) -> UIViewController.Type? {
        return matcher.match(pattern: pattern.rawValue, with: rootNode)?.matchedNode.viewControllerType
    }
    
    /// 根据指定的URL初始化在注册表中的VC
    /// - Parameter url: URL
    /// - Parameter params: 初始化参数
    func instantiatedViewController(for pattern: Name, params: [String : Any]? = nil) -> UIViewController? {
        guard let type = matcher.match(pattern: pattern.rawValue, with: rootNode)?.matchedNode.viewControllerType else { return nil }
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
    
    func push(pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.push).subtracting(.present)
        open(pattern: pattern, parameters: parameters, option: opt, tabBarOpenType: tabBarOpenType, completion: completion)
    }
    
    func present(pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.present).subtracting(.push)
        open(pattern: pattern, parameters: parameters, option: opt, tabBarOpenType: tabBarOpenType, completion: completion)
    }
    
    func open(pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let result = matcher.match(pattern: pattern.rawValue, with: rootNode)
        
        let context = RoutingContext(originalURL: pattern.rawValue, params: parameters, placeholders: result?.placeholders, viewControllerType: result?.matchedNode.viewControllerType, completion: completion)
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
