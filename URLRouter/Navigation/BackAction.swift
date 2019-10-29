//
//  BackAction.swift
//  URLRouter
//
//  Created by Michael on 2019/10/29.
//

import Foundation

class BackAction {
    
     static func back(on viewController: UIViewController?, useTopMost: Bool = false, animated: Bool = true) {
        
        if let navigationController = viewController as? UINavigationController {
            
            backOnNavigationController(navigationController, useTopMost: useTopMost, animated: true)
            
        } else if let tabBarController = viewController as? UITabBarController {
            
            guard let tabViewControllers = tabBarController.viewControllers,
                  let navigationController = tabViewControllers[tabBarController.selectedIndex] as? UINavigationController
            else { return }
            
            backOnNavigationController(navigationController, useTopMost: useTopMost, animated: animated)
        }
    }
    
    private static func backOnNavigationController(_ navigationController: UINavigationController, useTopMost: Bool, animated: Bool) {
        guard let navigationController = useTopMost ? navigationController.topMostNavigation : navigationController else { return }
        
        ModalAction.dismissModal(for: navigationController, animated: animated) {
            navigationController.popViewController(animated: animated)
        }
    }
    
}
