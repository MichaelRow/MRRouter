//
//  PresentAction.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

protocol PresentActionDelegate: class {
    
    func presentAction(_ action: PresentAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController?
    
    /// 即将模态弹出
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func presentAction(_ action: PresentAction, willPresent context: RoutingContext?)
    
    /// 完成模态弹出
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func presentAction(_ action: PresentAction, didPresent context: RoutingContext?)
    
    /// 模态弹出失败
    /// - Parameter context: 上下文。nil时为处理非注册VC跳转
    func presentAction(_ action: PresentAction, context: RoutingContext?, failPresent error: RouterError)
}

class PresentAction {
    
    weak var delegate: PresentActionDelegate?
    
    func present(on presenting: UIViewController?, context: RoutingContext) {
        
        guard let presenting = presenting else {
            delegate?.presentAction(self, context: context, failPresent: .noVCInStack)
            return
        }
        
        if let storedVC = context.storedVC,
           let canNavigate = presenting.topMost?.navigatable?.viewControllerCanNavigate?(with: context.params, viewControllerType: storedVC.viewControllerType),
           !canNavigate {
            delegate?.presentAction(self, context: context, failPresent: .rejectNavigate)
            return
        }
        
        delegate?.presentAction(self, willPresent: context)
        
        ModalAction.dismissModalIfNeeded(for: presenting, context: context) {
            guard let newVC = self.delegate?.presentAction(self, instantiatedViewControllerFor: context)
            else {
                self.delegate?.presentAction(self, context: context, failPresent: .instantiateVCFailed)
                return
            }
            
            if context.option.contains(.automaticModal) {
                if #available(iOS 13.0, *) {
                    newVC.modalPresentationStyle = .automatic
                } else {
                    newVC.modalPresentationStyle = .fullScreen
                }
            } else if context.option.contains(.customModal) {
                newVC.modalPresentationStyle = .custom
            } else {
                newVC.modalPresentationStyle = .fullScreen
            }
            
            presenting.topMost?.present(newVC, animated: !context.option.contains(.withoutAnimation)) {
                context.completion?(nil)
                self.delegate?.presentAction(self, didPresent: context)
            }
        }
    }
    
    func present(viewController: UIViewController, on presenting: UIViewController?, option: RoutingOption, completion: RouterCompletion?) {
        
        guard let presenting = presenting else {
            completion?(.noVCInStack)
            delegate?.presentAction(self, context: nil, failPresent: .noVCInStack)
            return
        }
        
        if let canNavigate = presenting.topMost?.navigatable?.viewControllerCanNavigate?(with: [:], viewControllerType: type(of: viewController)),
           !canNavigate {
            completion?(.rejectNavigate)
            delegate?.presentAction(self, context: nil, failPresent: .rejectNavigate)
            return
        }
        
        if option.contains(.automaticModal) {
            if #available(iOS 13.0, *) {
                viewController.modalPresentationStyle = .automatic
            } else {
                viewController.modalPresentationStyle = .fullScreen
            }
        } else if option.contains(.customModal) {
            viewController.modalPresentationStyle = .custom
        } else {
            viewController.modalPresentationStyle = .fullScreen
        }
        
        delegate?.presentAction(self, willPresent: nil)
        
        ModalAction.dismissModalIfNeeded(for: presenting, option: option) {
            presenting.topMost?.present(viewController, animated: !option.contains(.withoutAnimation)) {
                completion?(nil)
                self.delegate?.presentAction(self, didPresent: nil)
            }
        }
    }
}
