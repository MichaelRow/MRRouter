//
//  OCRouter.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/29.
//

import Foundation

/// 提供给OC简单跳转的接口
@objc public class OCRouter: NSObject {
    
    /// 使用VC注册路由
    @objc func register(url: String, viewControllerType: UIViewController.Type) {
        Router.shared.register(Router.Name(url: url), storedVC: .type(viewControllerType))
    }
    
    @objc func register(url: String, viewControllerType: UIViewController.Type, constructor: @escaping () -> UIViewController) {
        Router.shared.register(Router.Name(url: url), storedVC: .constructor(constructor, viewControllerType))
    }
    
    @objc func unregister(url: String, removeGrandchild: Bool = false) {
        Router.shared.unregister(Router.Name(url: url))
    }
    
    @objc public func canOpen(url: String) -> Bool {
        return Router.shared.canOpen(url: url)
    }
    
    @objc func back(_ useTopMost: Bool, animated: Bool) {
        return Router.shared.back(useTopMost, animated: animated)
    }
    
    @objc func push(url: String, parameters: [String : Any]? = nil) {
        Router.shared.push(Router.Name(url: url), parameters: parameters)
    }
    
    @objc func present(url: String, parameters: [String : Any]? = nil) {
        Router.shared.present(Router.Name(url: url), parameters: parameters)
    }
    
    @objc func open(url: String, parameters: [String : Any]? = nil) {
        Router.shared.open(Router.Name(url: url), parameters: parameters)
    }
}
