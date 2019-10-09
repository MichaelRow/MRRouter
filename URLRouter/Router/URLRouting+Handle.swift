//
//  URLRouting+Handle.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/14.
//

public extension URLRouting {
        
    func handle(_ context: RoutingContext) {
        guard handleResolvers(context) else {
            context.completion?()
            return
        }
        
        handleAsyncHandlers(context) { success in
            guard success else {
                context.completion?()
                return
            }
            
            if handleRedirectors(context) {
                return
            } else {
                
                if let navigationHandler = navigationHandler {
                    navigationHandler()
                } else {
                    nestRouter?.navigator.open(context: context)
                }
            }
        }
    }
    
    /// 处理路由参数
    /// - Parameter context: 上下文
    /// - Returns: 是否正常执行
    private func handleResolvers(_ context: RoutingContext) -> Bool {
        for resolver in resolvers {
            guard resolver.canHandle else { continue }
            guard resolver.handle(context) else { return false }
        }
        return true
    }
    
    private func handleAsyncHandlers(_ context: RoutingContext, _ completion: (Bool) -> Void) {
        var enumerator = asyncHandlers.makeIterator()
        iterate(&enumerator, context: context, completion: completion)
    }
    
    private func iterate(_ enumerator: inout IndexingIterator<[URLParameterAsyncHandler]>, context: RoutingContext, completion: (Bool) -> Void) {
        guard let asyncHandler = enumerator.next() else {
            completion(true)
            return
        }
        guard asyncHandler.canHandle else {
            iterate(&enumerator, context: context, completion: completion)
            return
        }
        asyncHandler.handle(context) { success in
            guard success else {
                completion(false)
                return
            }
            iterate(&enumerator, context: context, completion: completion)
        }
    }
    
    /// 是否发生重定向
    /// - Parameter context: 上下文
    /// - Returns: 是否重定向
    private func handleRedirectors(_ context: RoutingContext) -> Bool {
        for redirector in redirectors {
            if redirector.canHandle, let url = redirector.handle(context) {
                nestRouter?.open(url: url, parameters: context.params, completion: context.completion)
                return true
            }
        }
        return false
    }
    
}
