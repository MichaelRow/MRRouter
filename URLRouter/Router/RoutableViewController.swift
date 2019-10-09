//
//  RoutableViewController.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/15.
//

public protocol RoutableViewController: class {
    
    static var stackLevel: StackLevel { get }
    
    var parameters: [String : Any] { get set }
    
    /// 使用字典初始化，需要将parameters赋值给RoutableViewController.parameters
    /// - Parameter parameters: 跳转字典
    init(_ parameters: [String : Any])
    
    /// 即将更新当前控制器参数，当需要跳转的VC是存在于页面栈中时调用
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 跳转上下文
    func viewControllerWillUpdateParameters(by navigator: Navigator, context: RoutingContext)
    
    /// 当前控制器参数更新完成，当需要跳转的VC是存在于页面栈中时调用
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 跳转上下文
    func viewControllerDidUpdateParameters(by navigator: Navigator, context: RoutingContext)
    
    /// 是否能执行跳转
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 跳转上下文
    func viewControllerCanNavigate(by navigator: Navigator, context: RoutingContext) -> Bool
} 

public extension RoutableViewController {
    
    func viewControllerWillUpdateParameters(by navigator: Navigator, context: RoutingContext) {}
    
    func viewControllerDidUpdateParameters(by navigator: Navigator, context: RoutingContext) {}
    
    func viewControllerCanNavigate(by navigator: Navigator, context: RoutingContext) -> Bool { return true }
}
