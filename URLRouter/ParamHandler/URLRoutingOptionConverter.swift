//
//  URLRoutingOptionConverter.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/6.
//

import Foundation

public struct URLRoutingOptionConverter: URLParameterHandler {
    
    public var canHandle: Bool { return true }
    
    public var priority: Priority { return .medium }
    
    public func handle(_ context: RoutingContext) -> Bool {
        var option = context.option
        Router.Option.allCases.forEach { routerOpt in
            guard let flag = context[routerOpt] else { return }
            if flag {
                option.insert(routerOpt.optionValue)
            } else {
                option.remove(routerOpt.optionValue)
            }
        }
        context.option = option
        return true
    }
    
    public var description: String {
        return "[\(type(of: self))]:URL参数转RoutingOption"
    }
}
