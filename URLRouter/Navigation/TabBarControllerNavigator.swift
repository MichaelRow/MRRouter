//
//  TabBarControllerNavigator.swift
//  URLRouter
//
//  Created by Michael on 2019/9/27.
//

import UIKit

open class TabBarControllerNavigator: Navigator {
    
    //TODO: 这种嵌套的代码复用方式不太合适
    private var navigationControllerNavigator: NavigationControllerNavigator
    
    public weak var delegate: NavigatorDelegate?
    
    public weak var rootTabBarController: UITabBarController?
        
    public var wrapperType: UINavigationController.Type
    
    public var navigatorViewController: UIViewController? { return rootTabBarController }
    
    /// 初始化基于UITabBarController的跳转控制器
    /// - Parameter tabBarController: 跳转执行的TabBarController，如果不设值，则尝试用keyWindow根视图控制器
    /// - Parameter wrapperType: 模态弹出时用的包装导航控制器
    public init(_ tabBarController: UITabBarController? = nil, wrapperType: UINavigationController.Type = UINavigationController.self) {
        self.rootTabBarController = tabBarController ?? UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
        self.wrapperType = wrapperType
        self.navigationControllerNavigator = NavigationControllerNavigator(nil, wrapperType: wrapperType)
        self.navigationControllerNavigator.delegate = self
    }
    
    public func open(context: RoutingContext) {
        guard context.viewControllerType != nil,
              navigatorViewController != nil
        else {
            context.completion?()
            return
        }
        if context.option.contains(.push) {
            push(context: context)
        } else if context.option.contains(.present) {
            present(context: context)
        } else {
            push(context: context)
        }
    }
    
    public func push(context: RoutingContext) {
        guard let tabBarController = rootTabBarController,
              let tabViewControllers = tabBarController.viewControllers
        else {
            context.completion?()
            return
        }
                
        let toIndex = context.toTabBarIndex == nil ? tabBarController.selectedIndex : context.toTabBarIndex!
        guard toIndex < 5,
              toIndex < tabViewControllers.count,
              let navigationController = tabViewControllers[toIndex] as? UINavigationController
        else {
            context.completion?()
            return
        }
        
        if toIndex == tabBarController.selectedIndex {
            navigationControllerNavigator.rootNavigationController = navigationController
            navigationControllerNavigator.open(context: context)
        } else {
            dismissModal(context)
            rootTabBarController?.selectedIndex = toIndex
            navigationControllerNavigator.rootNavigationController = navigationController
            navigationControllerNavigator.open(context: context)
        }
    }
}

extension TabBarControllerNavigator: NavigatorDelegate {
    
    public func navigator(_ navigator: Navigator, willPresent context: RoutingContext) {}
    public func navigator(_ navigator: Navigator, didPresent context: RoutingContext) {}
    
    public func navigator(_ navigator: Navigator, willPush stackType: StackType) {
        delegate?.navigator(navigator, willPush: stackType)
    }
    
    public func navigator(_ navigator: Navigator, didPush stackType: StackType) {
        delegate?.navigator(navigator, didPush: stackType)
    }
}
