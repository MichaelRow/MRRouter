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
    
    func open(context: RoutingContext)
    
    func present(context: RoutingContext)
    
    func push(context: RoutingContext)
}
