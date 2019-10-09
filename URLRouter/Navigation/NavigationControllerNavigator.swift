//
//  NavigationControllerNavigator.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/7.
//

import UIKit

open class NavigationControllerNavigator: Navigator {
    
    public weak var delegate: NavigatorDelegate?
    
    public weak var rootNavigationController: UINavigationController?
            
    public var wrapperType: UINavigationController.Type
        
    public var navigatorViewController: UIViewController? { return rootNavigationController }
    
    /// 初始化基于UINavigationController的跳转控制器
    /// - Parameter tabBarController: 跳转执行的NavigationController，如果不设值，则尝试用keyWindow根视图控制器
    /// - Parameter wrapperType: 模态弹出时用的包装导航控制器
    public init(_ navigation: UINavigationController?, wrapperType: UINavigationController.Type = UINavigationController.self) {
        self.rootNavigationController = navigation ?? UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        self.wrapperType = wrapperType
    }
    
    public func open(context: RoutingContext) {
        guard context.viewControllerType != nil,
              rootNavigationController != nil
        else { return }
        if context.option.contains(.push) {
            push(context: context)
        } else if context.option.contains(.present) {
            present(context: context)
        } else {
            push(context: context)
        }
    }

    public func push(context: RoutingContext) {
        dismissModalIfNeeded(context) {
            // 先找到合适的导航栏控制器
            guard let navigationController = context.option.contains(.useTopMostNavigation) ? self.topMostNavigation : self.rootNavigationController else { return }
            
            self.dismissModal(for: navigationController, animated: !context.option.contains(.withoutDismissalAnimation)) {
                // 根据优先级处理出入页面栈逻辑
                let stackHandleResult = self.resolveStackType(for: navigationController, context: context)
                
                self.delegate?.navigator(self, willPush: stackHandleResult.stackType)
                
                switch stackHandleResult.stackType {
                case .push:
                    self.handlePush(context, navigationController: navigationController)
                case .refreshParameters:
                    self.handleRefreshParameter(context, navigationController: navigationController)
                case .replace:
                    self.handleReplace(context, navigationController: navigationController)
                case .popThenInsert:
                    self.handlePopThenInsert(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .popThenReplace:
                    self.handlePopThenReplace(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .popThenRefreshParameters:
                    self.handlePopThenRefreshParameters(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .doNothing:
                    break
                }
                
                context.completion?()
                
                self.delegate?.navigator(self, didPush: stackHandleResult.stackType)
            }
        }
    }
    
    //MARK: - Push Handling
    
    private func handlePush(_ context: RoutingContext, navigationController: UINavigationController) {
        guard let viewController = instantiateViewController(context) else { return }
        navigationController.pushViewController(viewController, animated: !context.option.contains(.withoutAnimation))
    }
    
    private func handleRefreshParameter(_ context: RoutingContext, navigationController: UINavigationController) {
        guard let targetVC = navigationController.topViewController else { return }
        targetVC.routable?.viewControllerWillUpdateParameters(by: self, context: context)
        targetVC.routable?.parameters = context.params
        targetVC.routable?.viewControllerDidUpdateParameters(by: self, context: context)
    }
    
    private func handleReplace(_ context: RoutingContext, navigationController: UINavigationController) {
        guard let viewController = instantiateViewController(context) else { return }
        var stackVCs = navigationController.viewControllers
        stackVCs.removeLast()
        stackVCs.append(viewController)
        navigationController.setViewControllers(stackVCs, animated: context.option.contains(.popReplaceAnimation))
    }
    
    private func handlePopThenInsert(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) {
        guard let index = index,
              let viewController = instantiateViewController(context)
        else { return }
        var stackVCs = navigationController.viewControllers[0...index]
        stackVCs.append(viewController)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
    }
    
    private func handlePopThenReplace(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) {
        guard let index = index,
              let viewController = instantiateViewController(context)
        else { return }
        var stackVCs = navigationController.viewControllers[0...index]
        stackVCs.removeLast()
        stackVCs.append(viewController)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
    }
    
    private func handlePopThenRefreshParameters(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) {
        guard let index = index else { return }
        let stackVCs = navigationController.viewControllers[0...index]
        guard let lastVC = stackVCs.last else { return }
        lastVC.routable?.viewControllerWillUpdateParameters(by: self, context: context)
        lastVC.routable?.parameters = context.params
        lastVC.routable?.viewControllerDidUpdateParameters(by: self, context: context)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
    }
    
    //MARK: - Stack Handling
    
    private func resolveStackType(for navigationController: UINavigationController, context: RoutingContext) -> (stackType: StackType, popToIndex: Int?) {
        //不需要考虑栈等级
        guard !context.option.contains(.ignoreLevel) else { return (.push, nil) }
        
        let stackVCs = navigationController.viewControllers
        //没有栈顶VC的异常情况
        guard let lastVC = stackVCs.last else { return (.doNothing, nil) }
        
        let lastVCType = type(of: lastVC)
        // 无法比较栈等级的情况直接压栈
        guard let newVCLevel = context.viewControllerType?.routable?.stackLevel,
              let lastVCLevel = lastVCType.routable?.stackLevel
        else {
            return (.push, nil)
        }
        
        var stackType = StackType.doNothing
        var popToIndex: Int? = nil
        
        if newVCLevel > lastVCLevel {
            stackType = .push
        } else if newVCLevel == lastVCLevel {
            //如果是同样的VC，只替换VC参数
            if context.viewControllerType == lastVCType {
                stackType = .refreshParameters
            } else {
                stackType = .replace
            }
        } else {
            //如果Navi只有一个VC，那么直接替换
            guard stackVCs.count >= 2 else {
                return (.replace, nil)
            }
            
            //已经判断过栈顶，从倒数第二个开始查找
            for index in (0 ..< stackVCs.count - 1).reversed() {
                
                let currentNode = stackVCs[index]
                let currentVCType = type(of: currentNode)
                
                //无法比较栈等级，替换该VC前面的VC
                guard let currentLevel = currentVCType.routable?.stackLevel else {
                    return (.popThenInsert, index)
                }
                
                if newVCLevel > currentLevel {
                    stackType = .popThenInsert
                    popToIndex = index
                    break
                } else if newVCLevel == currentLevel {
                    //如果是同样的VC，只替换VC参数
                    if context.viewControllerType == currentVCType {
                        stackType = .popThenRefreshParameters
                    } else {
                        stackType = .popThenReplace
                    }
                    popToIndex = index
                    break
                }
                //到了尽头没找到符合条件的栈，替换整个Navi堆栈
                if index == 0 {
                    stackType = .popThenReplace
                    popToIndex = 0
                }
            }
        }
        
        return (stackType, popToIndex)
    }
    
}
