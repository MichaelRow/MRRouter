//
//  NavigatorDelegate.swift
//  URLRouter
//
//  Created by Michael on 2019/10/9.
//

public protocol NavigatorDelegate: class {
        
    func navigator(_ navigator: Navigator, willPresent context: RoutingContext)
    
    func navigator(_ navigator: Navigator, didPresent context: RoutingContext)
    
    func navigator(_ navigator: Navigator, failedPresent context: RoutingContext, error: RouterError)
    
    func navigator(_ navigator: Navigator, willPush context: RoutingContext, stackType: StackType)
    
    func navigator(_ navigator: Navigator, didPush context: RoutingContext, stackType: StackType)
    
    func navigator(_ navigator: Navigator, failedPush context: RoutingContext, error: RouterError)
}
