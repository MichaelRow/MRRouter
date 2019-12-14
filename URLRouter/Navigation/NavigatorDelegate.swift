//
//  NavigatorDelegate.swift
//  URLRouter
//
//  Created by Michael on 2019/10/9.
//

public protocol NavigatorDelegate: class {
    
    /// 即将模态弹出
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, willPresent context: RoutingContext?)
    
    /// 结束模态弹出
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, didPresent context: RoutingContext?)
    
    /// 模态弹出失败
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, failedPresent context: RoutingContext?, error: RouterError)
    
    /// 即将push压栈
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, willPush context: RoutingContext?, stackType: StackType)
    
    /// 结束push压栈
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, didPush context: RoutingContext?, stackType: StackType)
    
    /// push压栈失败
    /// - Parameter navigator: 跳转控制器
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func navigator(_ navigator: Navigator, failedPush context: RoutingContext?, error: RouterError)
}
