//
//  ModalAction.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

import Foundation

public struct ModalAction {
    
    public static func dismissModalIfNeeded(for viewController: UIViewController, option: RoutingOption, completion: (() -> Void)? = nil) {
        if option.contains(.dismissModal) {
            dismissModal(for: viewController, animated: !option.contains(.withoutDismissalAnimation)) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    public static func dismissModalIfNeeded(for viewController: UIViewController?, context: RoutingContext, completion: (() -> Void)? = nil) {
        if context.option.contains(.dismissModal) {
            dismissModal(for: viewController, context: context) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    /// 关闭指定VC上的所有模态
    /// - Parameter viewController: 需要关闭模态的VC
    /// - Parameter context: 跳转上下文
    /// - Parameter completion: 完成后的回调
    public static func dismissModal(for viewController: UIViewController?, context: RoutingContext, completion: (() -> Void)? = nil) {
        if let presentedVC = viewController?.presentedViewController {
            dismissModalNoAnimation(for: presentedVC) {
                presentedVC.dismiss(animated: !context.option.contains(.withoutDismissalAnimation), completion: completion)
            }
        } else {
            completion?()
        }
    }
    
    /// 关闭指定VC上的所有模态
    /// - Parameter viewController: 需要关闭模态的VC
    /// - Parameter animated: 是否保留最后一次的动画
    /// - Parameter completion: 完成后的回调
    public static func dismissModal(for viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedVC = viewController.presentedViewController else {
            completion?()
            return
        }
        dismissModalNoAnimation(for: presentedVC) {
            presentedVC.dismiss(animated: animated, completion: completion)
        }
    }
    
    /// 关闭指定VC上的所有模态
    /// - Parameter viewController: 需要关闭模态的VC
    /// - Parameter completion: 完成后的回调
    public static func dismissModalNoAnimation(for viewController: UIViewController, completion: @escaping () -> Void) {
        guard let presentedVC = viewController.presentedViewController else {
            completion()
            return
        }
        dismissModalNoAnimation(for: presentedVC) {
            presentedVC.dismiss(animated: false) {
                completion()
            }
        }
    }
    
    private init() {}
}
