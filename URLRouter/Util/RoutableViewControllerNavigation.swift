//
//  RoutableViewControllerNavigation.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/15.
//

import UIKit

@objc public protocol RoutableViewControllerNavigation: RoutableViewController {
    /// 即将更新当前控制器参数，当需要跳转的VC是存在于页面栈中时调用
    /// - Parameter context: 跳转上下文
    @objc optional func viewControllerWillUpdate(parameter: [String : Any])
    
    /// 当前控制器参数更新完成，当需要跳转的VC是存在于页面栈中时调用
    /// - Parameter context: 跳转上下文
    @objc optional func viewControllerDidUpdate(parameter: [String : Any])
    
    /// 是否能执行跳转
    /// - Parameter context: 跳转上下文
    @objc optional func viewControllerCanNavigate(with parameter: [String : Any], viewControllerType: UIViewController.Type) -> Bool
}
