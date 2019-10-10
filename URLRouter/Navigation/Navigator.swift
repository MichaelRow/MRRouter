//
//  Navigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

public protocol Navigator: class {
    
    var delegate: NavigatorDelegate? { get set }
    
    /// 模态弹出时用的包装导航控制器
    var wrapperType: UINavigationController.Type { get set }
    
    func open(context: RoutingContext)
    
    func present(context: RoutingContext)
    
    func push(context: RoutingContext)
}

extension Navigator {
    
    func instantiateViewController(_ context: RoutingContext) -> UIViewController? {
        guard let viewController = context.instantiateViewController() else { return nil }
        if context.option.contains(.wrapInNavigation), !context.option.contains(.push) {
            let navi = wrapperType.init(rootViewController: viewController)
            navi.navigationBar.isTranslucent = false
            return navi
        } else {
            return viewController
        }
    }
}
