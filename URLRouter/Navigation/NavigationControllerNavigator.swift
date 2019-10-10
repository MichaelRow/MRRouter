//
//  NavigationControllerNavigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class NavigationControllerNavigator: Navigator {
    
    public weak var delegate: NavigatorDelegate?
    
    public weak var rootNavigationController: UINavigationController?
            
    public var wrapperType: UINavigationController.Type
            
    private var pushAction: PushAction
    
    private var presentAction: PresentAction
    
    /// 初始化基于UINavigationController的跳转控制器
    /// - Parameter tabBarController: 跳转执行的NavigationController，如果不设值，则尝试用keyWindow根视图控制器
    /// - Parameter wrapperType: 模态弹出时用的包装导航控制器
    public init(_ navigation: UINavigationController? = nil, wrapperType: UINavigationController.Type = UINavigationController.self) {
        self.wrapperType = wrapperType
        
        rootNavigationController = navigation ?? UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        pushAction = PushAction()
        presentAction = PresentAction()
        
        pushAction.delegate = self
        presentAction.delegate = self
    }
    
    public func open(context: RoutingContext) {
        guard context.viewControllerType != nil,
              rootNavigationController != nil
        else {
            context.completion?(.essitialCheckFail)
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

    public func present(context: RoutingContext) {
        presentAction.present(on: rootNavigationController, context: context)
    }
    
    public func push(context: RoutingContext) {
        pushAction.push(on: rootNavigationController, context: context)
    }
    
}

extension NavigationControllerNavigator: PushActionDelegate {
    
    func pushAction(_ action: PushAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController? {
        return instantiateViewController(context)
    }
    
    func pushAction(_ action: PushAction, willPush context: RoutingContext, stackType: StackType) {
        delegate?.navigator(self, willPush: context, stackType: stackType)
    }
    
    func pushAction(_ action: PushAction, didPush context: RoutingContext, stackType: StackType) {
        delegate?.navigator(self, didPush: context, stackType: stackType)
        context.completion?(nil)
    }
    
    func pushAction(_ action: PushAction, context: RoutingContext, failPresent error: RouterError) {
        delegate?.navigator(self, failedPush: context, error: error)
        context.completion?(error)
    }
}

extension NavigationControllerNavigator: PresentActionDelegate {
    
    func presentAction(_ action: PresentAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController? {
        return instantiateViewController(context)
    }
    
    func presentAction(_ action: PresentAction, willPresent context: RoutingContext) {
        delegate?.navigator(self, willPresent: context)
    }
    
    func presentAction(_ action: PresentAction, didPresent context: RoutingContext) {
        delegate?.navigator(self, didPresent: context)
        context.completion?(nil)
    }
    
    func presentAction(_ action: PresentAction, context: RoutingContext, failPresent error: RouterError) {
        delegate?.navigator(self, failedPresent: context, error: error)
        context.completion?(error)
    }
}
