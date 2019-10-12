//
//  DebugMapper.swift
//  URLRouter_Example
//
//  Created by Michael on 2019/9/29.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import URLRouter

class DebugMapper {
                
    static let shared = DebugMapper()
    
    func registerURLs() {
        Router.shared.register(pattern: "routerA://title", viewControllerType: TitleViewController.self)
        Router.shared.register(pattern: "routerA://general/setting", viewControllerType: SettingVC.self)
        Router.shared.register(pattern: "routerA://general/zone", viewControllerType: ZoneVC.self)
        Router.shared.register(pattern: "routerA://general/<AnyParams>", viewControllerType: AnyParamsVC.self)
        Router.shared.register(pattern: "routerB://title", viewControllerType: TitleViewController.self)
        Router.shared.register(pattern: "routerC://news", viewControllerType: NewsVC.self)
        Router.shared.register(pattern: "routerC://kline", viewControllerType: KLineVC.self)
    }
    
    var navigateActions: [NavigateActionModel] = {
        var actions = [NavigateActionModel]()
        
        actions.append(NavigateActionModel(name: "withoutAnimation", option: [.withoutAnimation]))
        actions.append(NavigateActionModel(name: "useTopMostNavigation", option: [.useTopMostNavigation]))
        actions.append(NavigateActionModel(name: "wrapInNavigation", option: [.wrapInNavigation]))
        actions.append(NavigateActionModel(name: "dismissModal", option: [.dismissModal]))
        actions.append(NavigateActionModel(name: "withoutDismissalAnimation", option: [.withoutDismissalAnimation]))
        actions.append(NavigateActionModel(name: "ignoreLevel", option: [.ignoreLevel]))
        actions.append(NavigateActionModel(name: "popReplaceAnimation", option: [.popReplaceAnimation]))
        
        return actions
    }()
}
