//
//  ModalAction.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

import Foundation

public struct ModalAction {
    
    public static func dismissModalIfNeeded(for viewController: UIViewController?, context: RoutingContext, completion: (() -> Void)? = nil) {
        if context.option.contains(.dismissModal) {
            dismissModal(for: viewController, context: context) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    public static func dismissModal(for viewController: UIViewController?, context: RoutingContext, completion: (() -> Void)? = nil) {
        if let presentedVC = viewController?.presentedViewController {
            dismissModal(for: presentedVC) {
                presentedVC.dismiss(animated: !context.option.contains(.withoutDismissalAnimation), completion: completion)
            }
        } else {
            completion?()
        }
    }
    
    public static func dismissModal(for viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedVC = viewController.presentedViewController else {
            completion?()
            return
        }
        dismissModal(for: presentedVC) {
            presentedVC.dismiss(animated: animated, completion: completion)
        }
    }
    
    public static func dismissModal(for viewController: UIViewController, completion: @escaping () -> Void) {
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
    
    private init() {}
}
