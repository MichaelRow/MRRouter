//
//  PushAction.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

protocol PushActionDelegate: class {
    
    func pushAction(_ action: PushAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController?
    
    /// 即将push压栈
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func pushAction(_ action: PushAction, willPush context: RoutingContext?, stackType: StackType)
    
    /// 完成push压栈
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func pushAction(_ action: PushAction, didPush context: RoutingContext?, stackType: StackType)

    /// push压栈失败
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func pushAction(_ action: PushAction, context: RoutingContext?, failPresent error: RouterError)
}

class PushAction {
    
    weak var delegate: PushActionDelegate?
    
    public func push(_ viewController: UIViewController, on navigation: UINavigationController, option: RoutingOption, completion: RouterCompletion?) {
        if let canNavigate = navigation.topMost?.navigatable?.viewControllerCanNavigate?(with: [:], viewControllerType: type(of: viewController)),
           !canNavigate {
            completion?(.rejectNavigate)
            delegate?.pushAction(self, context: nil, failPresent: .rejectNavigate)
            return
        }
        
        ModalAction.dismissModalIfNeeded(for: navigation, option: option) {
            // 先找到合适的导航栏控制器
            guard let navigationController = option.contains(.useStackNavigation) ? navigation : navigation.topMostNavigation
            else {
                completion?(.noNavigationController)
                self.delegate?.pushAction(self, context: nil, failPresent: .noNavigationController)
                return
            }
            
            ModalAction.dismissModal(for: navigationController, animated: !option.contains(.withoutDismissalAnimation)) {
                self.delegate?.pushAction(self, willPush: nil, stackType: .push)
                if option.contains(.deleteVCWhenPushComplete) {
                    var VCs = navigationController.viewControllers
                    VCs.removeLast()
                    VCs.append(viewController)
                    navigationController.setViewControllers(VCs, animated: !option.contains(.withoutAnimation))
                } else {
                    navigationController.pushViewController(viewController, animated: !option.contains(.withoutAnimation))
                }
                self.delegate?.pushAction(self, didPush: nil, stackType: .push)
                completion?(nil)
            }
        }
    }
    
    func push(on navigation: UINavigationController, context: RoutingContext) {
        guard let storedVC = context.storedVC else {
            delegate?.pushAction(self, context: context, failPresent: .instantiateVCFailed)
            return
        }
        if let canNavigate = navigation.topMost?.navigatable?.viewControllerCanNavigate?(with: context.params, viewControllerType: storedVC.viewControllerType),
           !canNavigate {
            delegate?.pushAction(self, context: context, failPresent: .rejectNavigate)
            return
        }
        
        ModalAction.dismissModalIfNeeded(for: navigation, context: context) {
            // 先找到合适的导航栏控制器
            guard let navigationController = context.option.contains(.useStackNavigation) ? navigation : navigation.topMostNavigation
            else {
                self.delegate?.pushAction(self, context: context, failPresent: .noNavigationController)
                return
            }
            
            ModalAction.dismissModal(for: navigationController, animated: !context.option.contains(.withoutDismissalAnimation)) {
                // 根据优先级处理出入页面栈逻辑
                let stackHandleResult = self.resolveStackType(for: navigationController, context: context)
                var error: RouterError? = nil
                
                self.delegate?.pushAction(self, willPush: context, stackType: stackHandleResult.stackType)
                
                switch stackHandleResult.stackType {
                case .push:
                    error = self.handlePush(context, navigationController: navigationController)
                case .refreshParameters:
                    error = self.handleRefreshParameter(context, navigationController: navigationController)
                case .replace:
                    error = self.handleReplace(context, navigationController: navigationController)
                case .popThenInsert:
                    error = self.handlePopThenInsert(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .popThenReplace:
                    error = self.handlePopThenReplace(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .popThenRefreshParameters:
                    error = self.handlePopThenRefreshParameters(context, navigationController: navigationController, popToIndex: stackHandleResult.popToIndex)
                case .doNothing:
                    error = .noAction
                }
                
                if let error = error {
                    self.delegate?.pushAction(self, context: context, failPresent: error)
                } else {
                    self.delegate?.pushAction(self, didPush: context, stackType: stackHandleResult.stackType)
                }
            }
        }
    }
    
    //MARK: - Push Handling
    
    @discardableResult private func handlePush(_ context: RoutingContext, navigationController: UINavigationController) -> RouterError? {
        guard let viewController = delegate?.pushAction(self, instantiatedViewControllerFor: context) else { return .instantiateVCFailed }
        if context.option.contains(.deleteVCWhenPushComplete) {
            var VCs = navigationController.viewControllers
            VCs.removeLast()
            VCs.append(viewController)
            navigationController.setViewControllers(VCs, animated: !context.option.contains(.withoutAnimation))
        } else {
            navigationController.pushViewController(viewController, animated: !context.option.contains(.withoutAnimation))
        }
        return nil
    }
    
    @discardableResult private func handleRefreshParameter(_ context: RoutingContext, navigationController: UINavigationController) -> RouterError? {
        guard let targetVC = navigationController.topViewController else { return .getTopMostVCFailed }
        targetVC.navigatable?.viewControllerWillUpdate?(parameter: context.params)
        targetVC.routable?.parameters = context.params
        targetVC.navigatable?.viewControllerDidUpdate?(parameter: context.params)
        return nil
    }
    
    @discardableResult private func handleReplace(_ context: RoutingContext, navigationController: UINavigationController) -> RouterError? {
        guard let viewController = delegate?.pushAction(self, instantiatedViewControllerFor: context) else { return .instantiateVCFailed }
        var stackVCs = navigationController.viewControllers
        stackVCs.removeLast()
        stackVCs.append(viewController)
        navigationController.setViewControllers(stackVCs, animated: context.option.contains(.popReplaceAnimation))
        return nil
    }
    
    @discardableResult private func handlePopThenInsert(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) -> RouterError? {
        guard let index = index,
              let viewController = delegate?.pushAction(self, instantiatedViewControllerFor: context)
        else { return .instantiateVCFailed }
        
        var stackVCs = navigationController.viewControllers[0...index]
        stackVCs.append(viewController)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
        return nil
    }
    
    @discardableResult private func handlePopThenReplace(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) -> RouterError? {
        guard let index = index,
              let viewController = delegate?.pushAction(self, instantiatedViewControllerFor: context)
        else { return .instantiateVCFailed }
        
        var stackVCs = navigationController.viewControllers[0...index]
        stackVCs.removeLast()
        stackVCs.append(viewController)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
        return nil
    }
    
    @discardableResult private func handlePopThenRefreshParameters(_ context: RoutingContext, navigationController: UINavigationController, popToIndex index: Int?) -> RouterError? {
        guard let index = index else { return .noStackPopDestinationIndex }
        let stackVCs = navigationController.viewControllers[0...index]
        guard let lastVC = stackVCs.last else { return .noVCInStack }
        lastVC.navigatable?.viewControllerWillUpdate?(parameter: context.params)
        lastVC.routable?.parameters = context.params
        lastVC.navigatable?.viewControllerDidUpdate?(parameter: context.params)
        navigationController.setViewControllers(Array(stackVCs), animated: context.option.contains(.popReplaceAnimation))
        return nil
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
        guard let newVCLevel = context.storedVC?.viewControllerType.routable?.stackLevel,
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
            if context.storedVC?.viewControllerType == lastVCType {
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
                    if context.storedVC?.viewControllerType == currentVCType {
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
