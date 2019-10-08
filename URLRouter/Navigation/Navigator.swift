//
//  Navigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

public protocol Navigator: class {
    
    var navigatorViewController: UIViewController? { get }
    
    var nestWindow: UIWindow? { get }
    
    var wrapperType: UINavigationController.Type { get set }
    
    func open(context: URLRoutingContext)
    
    func present(context: URLRoutingContext)
    
    func push(context: URLRoutingContext)
}

public extension Navigator {
    
    var window: UIWindow? {
        return nestWindow ?? UIApplication.shared.keyWindow
    }
    
    var topMost: UIViewController? {
        guard let rootViewController = currentRootViewController else { return nil }
        return self.topMost(of: rootViewController)
    }
    
    var topMostNavigation: UINavigationController? {
        guard let topMostVC = topMost else { return nil }
        var currentVC: UIViewController? = topMostVC
        
        repeat {
            if let currentNaviController = currentVC as? UINavigationController {
                return currentNaviController
            } else if let naviController = currentVC?.navigationController {
                return naviController
            }
            
            currentVC = currentVC?.presentingViewController
            
        } while currentVC != nil
        
        return nil
    }
    
    private var currentRootViewController: UIViewController? {
        return window?.rootViewController
    }
    
    private func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }
        
        return viewController
    }
    
}

public extension Navigator {
    
    func present(context: URLRoutingContext) {
        dismissModalIfNeeded(context)
        guard let viewController = instantiateViewController(context) else { return }
        topMost?.present(viewController, animated: !context.option.contains(.withoutAnimation), completion: context.completion)
    }
    
    internal func dismissModalIfNeeded(_ context: URLRoutingContext, completion: (() -> Void)? = nil) {
        if context.option.contains(.dismissModal) {
            dismissModal(context) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    internal func dismissModal(_ context: URLRoutingContext, completion: (() -> Void)? = nil) {
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
    
    internal func instantiateViewController(_ context: URLRoutingContext) -> UIViewController? {
        guard let viewController = context.instantiateViewController() else { return nil }
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
