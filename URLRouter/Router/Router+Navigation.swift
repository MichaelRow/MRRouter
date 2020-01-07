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
    /// - Parameter routing: URL参数解析与重定向路径
    /// - Parameter tabBarIndex: 需要打开的tabBar位置
    /// - Parameter override: 是否覆盖
    func register(_ pattern: Name, storedVC: StoredVC, routing: URLRouting? = nil, tabBarIndex: Int? = nil, override: Bool = true) {
        var usedRouting = routing ?? wildcardRouting
        if usedRouting.nestRouter !== self {
            usedRouting.nestRouter = self
        }
        
        guard let patternComponents = pattern.rawValue.pathElement else { return }
        var currentNode = rootNode
        patternComponents.enumerated().forEach { (offset: Int, component: URLPathElement) in
            if offset == patternComponents.count - 1 {
                currentNode.add(child: component, storedVC: storedVC, routing: usedRouting, tabBarIndex: tabBarIndex, override: override)
            } else {
                currentNode.add(child: component, override: false)
                currentNode = currentNode[component]!
            }
        }
    }
    
    /// 注销注册表中的URL
    /// - Parameter removeGrandchild: 是否移除该节点之后的所有子节点
    func unregister(_ pattern: Name, removeGrandchild: Bool = false) {
        guard let matchedResult = matcher.match(pattern: pattern.rawValue, with: rootNode) else { return }
        matchedResult.matchedNode.parentNode?.remove(child: matchedResult.matchedNode.nodePattern, removeGrandchild: removeGrandchild)
    }
    
    /// 是否有注册当前URL
    func canOpen(url: URLConvertible) -> Bool {
        return matcher.match(pattern: url, with: rootNode)?.matchedNode.routing != nil
    }
    
    /// 是否有注册当前URL
    func canOpen(_ pattern: Name) -> Bool {
        return canOpen(url: pattern.rawValue)
    }
    
    /// 获得注册在Router中的VC类型。如果是.constructor方式注册，则返回nil。
    func registeredVCType(for pattern: Name) -> UIViewController.Type? {
        guard let storedVC = matcher.match(pattern: pattern.rawValue, with: rootNode)?.matchedNode.storedVC else { return nil }
        switch storedVC {
        case .type(let type):
            return type
        case .constructor(_, _):
            return nil
        }
    }
    
    /// 根据指定的URL初始化在注册表中的VC
    /// - Parameter url: URL
    /// - Parameter params: 初始化参数
    func instantiatedViewController(for pattern: Name, params: [String : Any]? = nil) -> UIViewController? {
        let vc = matcher.match(pattern: pattern.rawValue, with: rootNode)?.matchedNode.storedVC?.instantiatedViewController(for: params)
        vc?.routable?.parameters = params ?? [:]
        return vc
    }
    
    func back(_ useTopMost: Bool = true, animated: Bool = true) {
        navigator.back(useTopMost, animated: animated)
    }
    
    func dismiss(animated: Bool = true, completion: RouterCompletion? = nil) {
        navigator.dismiss(animated: animated, completion: completion)
    }
    
    func dismissLast(animated: Bool = true, completion: RouterCompletion? = nil) {
        navigator.dismissLast(animated: animated, completion: completion)
    }
    
    //MARK: - 注册VC
    
    func push(_ pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.push).subtracting(.present)
        open(pattern, parameters: parameters, option: opt, tabBarOpenType: tabBarOpenType, completion: completion)
    }
    
    func present(_ pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], completion: RouterCompletion? = nil) {
        let opt = option.union(.present).subtracting(.push)
        open(pattern, parameters: parameters, option: opt, tabBarOpenType: .preset, completion: completion)
    }
    
    func open(_ pattern: Name, parameters: [String : Any]? = nil, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let result = matcher.match(pattern: pattern.rawValue, with: rootNode)
        
        let context = RoutingContext(originalURL: pattern.rawValue, params: parameters, placeholders: result?.placeholders, storedVC: result?.matchedNode.storedVC, completion: completion)
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
    
    //MARK: - 未注册VC
    
    func push(viewController: UIViewController, option: RoutingOption = [], tabBarOpenType: TabBarOpenType = .preset, completion: RouterCompletion? = nil) {
        let opt = option.union(.push).subtracting(.present)
        let toIndex: Int?
        switch tabBarOpenType {
        case .current, .preset:
            toIndex = nil
        case .custom(let index):
            toIndex = index
        }
        navigator.push(viewController, option: opt, toTabBarIndex: toIndex, completion: completion)
    }
    
    func present(viewController: UIViewController, option: RoutingOption = [], completion: RouterCompletion? = nil) {
        let opt = option.union(.present).subtracting(.push)
        if option.contains(.wrapInNavigation) {
            let navi = self.wrapperType.init(rootViewController: viewController)
            navi.navigationBar.isTranslucent = false
            navigator.present(navi, option: opt, completion: completion)
        } else {
            navigator.present(viewController, option: opt, completion: completion)
        }
    }
}
