//
//  TabBarControllerNavigator.swift
//  URLRouter
//
//  Created by Michael on 2019/9/27.
//

import UIKit

open class TabBarControllerNavigator: Navigator {
    
    private var navigationControllerNavigator: NavigationControllerNavigator
    
    public weak var rootTabBarController: UITabBarController?
    
    public weak var nestWindow: UIWindow?
    
    public var wrapperType: UINavigationController.Type
    
    public var navigatorViewController: UIViewController? { return rootTabBarController }
    
    public init(_ tabBarController: UITabBarController?, window: UIWindow? = nil, wrapperType: UINavigationController.Type = UINavigationController.self) {
        self.rootTabBarController = tabBarController
        self.nestWindow = window
        self.wrapperType = wrapperType
        self.navigationControllerNavigator = NavigationControllerNavigator(nil, window: window, wrapperType: wrapperType)
    }
    
    public func open(context: URLRoutingContext) {
        guard context.viewControllerType != nil,
              navigatorViewController != nil
        else { return }
        if context.option.contains(.push) {
            push(context: context)
        } else if context.option.contains(.present) {
            present(context: context)
        } else {
            push(context: context)
        }
    }
    
    public func push(context: URLRoutingContext) {
        guard let tabBarController = rootTabBarController,
              let tabViewControllers = tabBarController.viewControllers
        else { return }
        
        let toIndex = context.toTabBarIndex == nil ? tabBarController.selectedIndex : context.toTabBarIndex!
        guard toIndex < 5,
              toIndex < tabViewControllers.count,
              let navigationController = tabViewControllers[toIndex] as? UINavigationController
        else { return }
        
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
