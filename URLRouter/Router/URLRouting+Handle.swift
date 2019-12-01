//
//  URLRouting+Handle.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/14.
//

public extension URLRouting {
        
    func handle(_ context: RoutingContext, completion:(RoutingContext, RouterError?) -> Void) {
        guard handleResolvers(context) else {
            completion(context, .resolveFailed)
            return
        }
        
        handleAsyncHandlers(context) { success in
            guard success else {
                completion(context, .asyncResolveFailed)
                return
            }
            
            if handleRedirectors(context) {
                completion(context, .redirection)
            } else {
                completion(context, nil)
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
                nestRouter?.open(pattern: Router.Name(url: url), parameters: context.params, completion: context.completion)
                return true
            }
        }
        return false
    }
    
}
