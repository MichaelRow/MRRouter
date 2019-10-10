//
//  Navigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

public protocol Navigator: class {
    
    var delegate: NavigatorDelegate? { get set }
    
    /// 用于跳转的控制器
    var navigatorViewController: UIViewController? { get }
    
    /// 模态弹出时用的包装导航控制器
    var wrapperType: UINavigationController.Type { get set }
    
    func open(context: RoutingContext)
    
    func present(context: RoutingContext)
    
    func push(context: RoutingContext)
}

public extension Navigator {
    
    func present(context: RoutingContext) {
        
        if let canNavigate = navigatorViewController?.topMost?.routable?.viewControllerCanNavigate(by: self, context: context), !canNavigate {
            context.completion?(.rejectNavigate)
            return
        }
        
        delegate?.navigator(self, willPresent: context)
        
        dismissModalIfNeeded(context)
        
        guard let viewController = instantiateViewController(context)
        else {
            context.completion?(.instantiateVCFailed)
            return
        }
        
        navigatorViewController?.topMost?.present(viewController, animated: !context.option.contains(.withoutAnimation)) {
            context.completion?(nil)
            
            self.delegate?.navigator(self, didPresent: context)
        }
    }
    
    internal func dismissModalIfNeeded(_ context: RoutingContext, completion: (() -> Void)? = nil) {
        if context.option.contains(.dismissModal) {
            dismissModal(context) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    internal func dismissModal(_ context: RoutingContext, completion: (() -> Void)? = nil) {
        if let presentedVC = navigatorViewController?.presentedViewController {
            dismissModal(for: presentedVC) {
                presentedVC.dismiss(animated: !context.option.contains(.withoutDismissalAnimation), completion: completion)
            }
        } else {
            completion?()
        }
    }
    
    internal func dismissModal(for viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        //如果需要dismiss presentedVC的viewController（以下称VC）有presentedVC，那么rootVC一定也有presentedVC
        guard let presentedVC = viewController.presentedViewController else {
            completion?()
            return
        }
        dismissModal(for: presentedVC) {
            presentedVC.dismiss(animated: animated, completion: completion)
        }
    }
    
    internal func dismissModal(for viewController: UIViewController, completion: @escaping () -> Void) {
        guard let presentedVC = viewController.presentedViewController else {
            completion()
            return
        }
        dismissModal(for: presentedVC) {
            presentedVC.dismiss(animated: false) {
                completion()
            }
        }
    }
    
    internal func instantiateViewController(_ context: RoutingContext) -> UIViewController? {
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
