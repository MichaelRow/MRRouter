//
//  Navigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

public protocol Navigator: class {
    
    var navigatorDelegate: NavigatorDelegate? { get set }
    
    /// 宿主窗口
    var nestWindow: UIWindow? { get set }
    
    /// 模态弹出时用的包装导航控制器
    var wrapperType: UINavigationController.Type { get set }
    
    func back(_ useTopMost: Bool, animated: Bool)
    
    func dismiss(animated: Bool, completion: RouterCompletion?)
    
    func dismissLast(animated: Bool, completion: RouterCompletion?)
    
    func open(context: RoutingContext)
    
    func present(context: RoutingContext)
    
    func push(context: RoutingContext)
        
    func push(_ viewController: UIViewController, option: RoutingOption, toTabBarIndex: Int?, completion: RouterCompletion?)
    
    func present(_ viewController: UIViewController, option: RoutingOption, completion: RouterCompletion?)
}

public extension Navigator {
    
    func instantiateViewController(_ context: RoutingContext) -> UIViewController? {
        guard let viewController = context.storedVC?.viewController else { return nil }
        viewController.routable?.parameters = context.params
        if context.option.contains(.wrapInNavigation), !context.option.contains(.push) {
            let navi = wrapperType.init(rootViewController: viewController)
            navi.navigationBar.isTranslucent = false
            return navi
        } else {
            return viewController
        }
    }
}
