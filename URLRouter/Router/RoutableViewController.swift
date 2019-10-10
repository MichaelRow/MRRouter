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
    /// - Parameter context: 跳转上下文
    func viewControllerWillUpdateParameters(with context: RoutingContext)
    
    /// 当前控制器参数更新完成，当需要跳转的VC是存在于页面栈中时调用
    /// - Parameter context: 跳转上下文
    func viewControllerDidUpdateParameters(with context: RoutingContext)
    
    /// 是否能执行跳转
    /// - Parameter context: 跳转上下文
    func viewControllerCanNavigate(with context: RoutingContext) -> Bool
} 

public extension RoutableViewController {
    
    func viewControllerWillUpdateParameters(with context: RoutingContext) {}
    
    func viewControllerDidUpdateParameters(with context: RoutingContext) {}
    
    func viewControllerCanNavigate(with context: RoutingContext) -> Bool { return true }
}
