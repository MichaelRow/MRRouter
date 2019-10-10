//
//  PresentAction.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/10.
//

protocol PresentActionDelegate: class {
    
    func presentAction(_ action: PresentAction, instantiatedViewControllerFor context: RoutingContext) -> UIViewController?
    func presentAction(_ action: PresentAction, willPresent context: RoutingContext)
    func presentAction(_ action: PresentAction, didPresent context: RoutingContext)
    func presentAction(_ action: PresentAction, context: RoutingContext, failPresent error: RouterError)
}

class PresentAction {
    
    weak var delegate: PresentActionDelegate?
    
    func present(on viewController: UIViewController?, context: RoutingContext) {
        
        guard let viewController = viewController else {
            delegate?.presentAction(self, context: context, failPresent: .noVCInStack)
            return
        }
        
        if let canNavigate = viewController.topMost?.routable?.viewControllerCanNavigate(with: context), !canNavigate {
            delegate?.presentAction(self, context: context, failPresent: .rejectNavigate)
            return
        }
        
        delegate?.presentAction(self, willPresent: context)
        
        ModalAction.dismissModalIfNeeded(for: viewController, context: context)
        
        guard let newVC = delegate?.presentAction(self, instantiatedViewControllerFor: context)
        else {
            delegate?.presentAction(self, context: context, failPresent: .instantiateVCFailed)
            return
        }
        
        viewController.topMost?.present(newVC, animated: !context.option.contains(.withoutAnimation)) {
            context.completion?(nil)
            self.delegate?.presentAction(self, didPresent: context)
        }
    }
    
}
