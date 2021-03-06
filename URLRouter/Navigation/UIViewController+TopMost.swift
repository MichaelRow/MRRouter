//
//  UIViewController+TopMost.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

import UIKit

public extension UIView {
    
    var topMost: UIViewController? {
        return  window?.rootViewController?.topMost
    }
}

public extension UIViewController {
    
    var navigation: UINavigationController? {
        guard let topMostVC = topMost else { return nil }
        var currentVC: UIViewController? = topMostVC
        var navi: UINavigationController? = nil
        repeat {
            if let currentNaviController = currentVC as? UINavigationController {
                navi = currentNaviController
            } else if let naviController = currentVC?.navigationController {
                navi = naviController
            }
            
            currentVC = currentVC?.presentedViewController
            
        } while currentVC != nil
        
        return navi
    }
    
    var topMost: UIViewController? {
        return topMost(of: self)
    }
    
    var topMostNavigation: UINavigationController? {
        guard let topMostVC = topMost else { return nil }
        var currentVC: UIViewController? = topMostVC
        
        repeat {
            if let currentNaviController = currentVC as? UINavigationController {
                return currentNaviController
                
            } else if let naviController = currentVC?.navigationController {
                return naviController
                
            } else if let tabBarController = currentVC as? UITabBarController,
                      let navi = tabBarController.selectedViewController as? UINavigationController {
                return navi
                
            } else if let pageViewController = currentVC as? UIPageViewController,
                      let naviController = pageViewController.viewControllers?.first as? UINavigationController {
                return naviController
            }
            
            currentVC = currentVC?.presentingViewController
            
        } while currentVC != nil
        
        return nil
    }
    
    private func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return topMost(of: pageViewController.viewControllers?.first)
        }
        
        return viewController
    }
    
}
