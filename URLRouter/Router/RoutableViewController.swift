//
//  RoutableViewController.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/15.
//

public protocol RoutableViewController: class {
    
    static var stackLevel: StackLevel { get }
    
    var parameters: [String : Any] { get set }
    
    init(_ parameters: [String : Any])
    
    func viewControllerWillUpdateParameters(by navigator: Navigator, context: URLRoutingContext)
    
    func viewControllerDidUpdateParameters(by navigator: Navigator, context: URLRoutingContext)
} 

extension RoutableViewController {
    
    func viewControllerWillUpdateParameters(by navigator: Navigator, context: URLRoutingContext) {}
    
    func viewControllerDidUpdateParameters(by navigator: Navigator, context: URLRoutingContext) {}
}