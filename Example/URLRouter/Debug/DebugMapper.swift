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
            
    var naviRouter = Router()
    var tabBarRouter = Router()
    var selectedRouter: Router?
    
    init(naviVC: UINavigationController, tabBarVC: UITabBarController, on window: UIWindow) {        
        let naviNavigator = NavigationControllerNavigator(naviVC, window: window)
        let naviRouting = URLRouting(navigator:naviNavigator)
        naviRouter.wildcardRouting = naviRouting
        
        let tabBarNavigator = TabBarControllerNavigator(tabBarVC, window: window)
        let tabBarRouting = URLRouting(navigator: tabBarNavigator)
        tabBarRouter.wildcardRouting = tabBarRouting
        
        selectedRouter = naviRouter
        
        registerURLs()
    }
    
    func registerURLs() {
        for router in [naviRouter,tabBarRouter] {
            router.register(pattern: "routerA://title", viewControllerType: TitleViewController.self)
            router.register(pattern: "routerA://general/setting", viewControllerType: SettingVC.self)
            router.register(pattern: "routerA://general/zone", viewControllerType: ZoneVC.self)
            router.register(pattern: "routerA://general/<AnyParams>", viewControllerType: AnyParamsVC.self)
            router.register(pattern: "routerB://title", viewControllerType: TitleViewController.self)
            router.register(pattern: "routerC://news", viewControllerType: NewsVC.self)
            router.register(pattern: "routerC://kline", viewControllerType: KLineVC.self)
        }
    }
    
    func switchRouter() {
        if selectedRouter != nil && selectedRouter! === naviRouter {
            selectedRouter = tabBarRouter
        } else {
            selectedRouter = naviRouter
        }
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
