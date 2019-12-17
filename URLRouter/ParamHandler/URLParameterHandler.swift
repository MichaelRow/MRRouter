//
//  URLParameterHandler.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/8.
//
@_exported import Define

public protocol URLParameterHandler: CustomStringConvertible {
    
    /// 是否能处理URL参数
    var canHandle: Bool { get }
    
    /// 处理优先级
    var priority: Priority { get }
    
    /// 处理URL参数
    ///
    /// - Parameter context: 路由上下文
    /// - Returns: 是否正常处理，异常情况终止路由
    func handle(_ context: RoutingContext) -> Bool
    
}

public protocol URLRedirectionHandler: CustomStringConvertible {
    
    /// 是否能处理URL参数
    var canHandle: Bool { get }
    
    /// 处理优先级
    var priority: Priority { get }
    
    /// 处理URL参数
    ///
    /// - Parameter context: 路由上下文
    /// - Returns: 重定向URL
    func handle(_ context: RoutingContext) -> URLConvertible?
    
}

public protocol URLParameterAsyncHandler: CustomStringConvertible {
    
    /// 是否能处理URL参数
    var canHandle: Bool { get }
    
    /// 处理优先级
    var priority: Priority { get }
    
    /// 处理URL参数
    ///
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - completion: 完成异步处理后回调，失败会终止路由
    func handle(_ context: RoutingContext, completion:((_ success: Bool) -> Void))
    
}
