//
//  GeneralNaigator.swift
//  URLRouter
//
//  Created by Michael on 2019/9/27.
//

import UIKit

open class GeneralNaigator: Navigator {
        
    public weak var navigatorDelegate: NavigatorDelegate?
    
    public weak var nestWindow: UIWindow?
        
    public var wrapperType: UINavigationController.Type
        
    private var pushAction: PushAction
    
    private var presentAction: PresentAction
        
    public init(_ nestWindow: UIWindow? = nil, wrapperType: UINavigationController.Type = UINavigationController.self) {
        self.nestWindow = nestWindow
        self.wrapperType = wrapperType
        
        pushAction = PushAction()
        presentAction = PresentAction()
        
        pushAction.delegate = self
        presentAction.delegate = self
    }
    
    public func back(_ useTopMost: Bool = true, animated: Bool = true) {
        BackAction.back(on: window?.rootViewController, useTopMost: useTopMost, animated: animated)
    }
    
    public func dismiss(animated: Bool = true, completion: RouterCompletion? = nil) {
        guard let rootVC = window?.rootViewController else {
            completion?(.getTopMostVCFailed)
            return
        }
        ModalAction.dismissModal(for: rootVC, animated: animated) {
            completion?(nil)
        }
    }
    
    public func dismissLast(animated: Bool = true, completion: RouterCompletion? = nil) {
        guard let topMost = window?.rootViewController?.topMost else {
            completion?(.getTopMostVCFailed)
            return
        }
        if let presented = topMost.presentedViewController {
            presented.dismiss(animated: animated) {
                completion?(nil)
            }
        }
    }
    
    public func open(context: RoutingContext) {
        guard context.storedVC != nil else {
            context.completion?(.essitialCheckFail)
            return
        }
        if context.option.contains(.push) {
            push(context: context)
        } else if context.option.contains(.present) {
            present(context: context)
        } else {
            push(context: context)
        }
    }
    
    public func present(context: RoutingContext) {
        presentAction.present(on: window?.rootViewController, context: context)
    }
    
    public func present(_ viewController: UIViewController, option: RoutingOption, completion: RouterCompletion?) {
        presentAction.present(viewController: viewController, on: window?.rootViewController, option: option, completion: completion)
    }
    
    //MARK: - Push
    
    public func push(context: RoutingContext) {
        navigationControllerForPush(toTabBarIndex: context.toTabBarIndex, option: context.option) { result in
            switch result {
            case .success(let navi):
                self.pushAction.push(on: navi, context: context)
            case .failure(let error):
                self.navigatorDelegate?.navigator(self, failedPush: context, error: error)
                context.completion?(error)
            }
        }
    }
    
    public func push(_ viewController: UIViewController, option: RoutingOption, toTabBarIndex: Int?, completion: RouterCompletion?) {
        navigationControllerForPush(toTabBarIndex: toTabBarIndex, option: option) { result in
            switch result {
            case .success(let navi):
                self.pushAction.push(viewController, on: navi, option: option, completion: completion)
            case .failure(let error):
                self.navigatorDelegate?.navigator(self, failedPush: nil, error: error)
                completion?(error)
            }
        }
    }
    
    private func navigationControllerForPush(toTabBarIndex: Int?, option: RoutingOption, completion: @escaping (Result<UINavigationController, RouterError>) -> Void) {
        guard let rootVC = window?.rootViewController else {
            completion(.failure(.getTopMostVCFailed))
            return
        }
        
        if let navi = rootVC as? UINavigationController {
            completion(.success(navi))
            
        } else if let tabBar = rootVC as? UITabBarController {
            
            guard let tabViewControllers = tabBar.viewControllers else {
                completion(.failure(.tabBarControllerError))
                return
            }
                    
            let toIndex = toTabBarIndex ?? tabBar.selectedIndex
            guard toIndex < 5,
                  toIndex < tabViewControllers.count,
                  let navigationController = tabViewControllers[toIndex] as? UINavigationController
            else {
                completion(.failure(.tabBarControllerError))
                return
            }
            
            if toIndex != tabBar.selectedIndex {
                ModalAction.dismissModalIfNeeded(for: tabBar, option: option) {
                    tabBar.selectedIndex = toIndex
                    completion(.success(navigationController))
                }
            } else {
                completion(.success(navigationController))
            }
        } else {
            completion(.failure(.getTopMostVCFailed))
        }
    }
}

extension GeneralNaigator: PushActionDelegate {
    
    func pushAction(_ action: PushAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController? {
        return instantiateViewController(context)
    }
    
    func pushAction(_ action: PushAction, willPush context: RoutingContext?, stackType: StackType) {
        navigatorDelegate?.navigator(self, willPush: context, stackType: stackType)
    }
    
    func pushAction(_ action: PushAction, didPush context: RoutingContext?, stackType: StackType) {
        navigatorDelegate?.navigator(self, didPush: context, stackType: stackType)
        
        // 非注册VC跳转return
        guard let context = context else { return }
        context.completion?(nil)
    }
    
    func pushAction(_ action: PushAction, context: RoutingContext?, failPresent error: RouterError) {
        navigatorDelegate?.navigator(self, failedPush: context, error: error)
        
        // 非注册VC跳转return
        guard let context = context else { return }
        context.completion?(error)
    }
}

extension GeneralNaigator: PresentActionDelegate {
    
    func presentAction(_ action: PresentAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController? {
        return instantiateViewController(context)
    }
    
    func presentAction(_ action: PresentAction, willPresent context: RoutingContext?) {
        navigatorDelegate?.navigator(self, willPresent: context)
    }
    
    func presentAction(_ action: PresentAction, didPresent context: RoutingContext?) {
        navigatorDelegate?.navigator(self, didPresent: context)
        
        // 非注册VC跳转return
        guard let context = context else { return }
        context.completion?(nil)
    }
    
    func presentAction(_ action: PresentAction, context: RoutingContext?, failPresent error: RouterError) {
        navigatorDelegate?.navigator(self, failedPresent: context, error: error)
        
        // 非注册VC跳转return
        guard let context = context else { return }
        context.completion?(error)
    }
}
