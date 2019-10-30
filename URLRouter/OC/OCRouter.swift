//
//  OCRouter.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/29.
//

import Foundation

/// 提供给OC简单跳转的接口
@objc public class OCRouter: NSObject {
    
    /// 使用符合RoutableViewController的VC注册路由
    @objc func register(pattern: String, viewControllerType: (UIViewController & RoutableViewController).Type) {
        Router.shared.register(pattern: pattern, viewControllerType: viewControllerType)
    }
    
    @objc func unregister(pattern: String, removeGrandchild: Bool = false) {
        Router.shared.unregister(pattern: pattern)
    }
    
    @objc public func canOpen(url: String) -> Bool {
        return Router.shared.canOpen(url: url)
    }
    
    @objc public func registeredViewController(for url: String) -> UIViewController.Type? {
        return Router.shared.registeredViewController(for: url)
    }
    
    @objc func back(_ useTopMost: Bool, animated: Bool) {
        return Router.shared.back(useTopMost, animated: animated)
    }
    
    @objc func push(url: String, parameters: [String : Any]? = nil) {
        Router.shared.push(url: url, parameters: parameters)
    }
    
    @objc func present(url: String, parameters: [String : Any]? = nil) {
        Router.shared.present(url: url, parameters: parameters)
    }
    
    @objc func open(url: String, parameters: [String : Any]? = nil) {
        Router.shared.open(url: url, parameters: parameters)
    }
}
