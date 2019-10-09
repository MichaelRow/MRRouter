//
//  NavigatorDelegate.swift
//  URLRouter
//
//  Created by Michael on 2019/10/9.
//

public protocol NavigatorDelegate: class {
        
    func navigator(_ navigator: Navigator, willPresent context: RoutingContext)
    
    func navigator(_ navigator: Navigator, didPresent context: RoutingContext)
    
    func navigator(_ navigator: Navigator, willPush stackType: StackType)
    
    func navigator(_ navigator: Navigator, didPush stackType: StackType)
}
