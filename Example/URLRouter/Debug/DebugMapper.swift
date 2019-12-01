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
        Router.shared.register(pattern: .title, storedVC: .type(TitleViewController.self))
        Router.shared.register(pattern: .setting, storedVC: .type(SettingVC.self))
        Router.shared.register(pattern: .general, storedVC: .type(GeneralVC.self), override: false)
        Router.shared.register(pattern: .zone, storedVC: .type(ZoneVC.self))
        Router.shared.register(pattern: .any, storedVC: .type(AnyParamsVC.self))
        Router.shared.register(pattern: .news, storedVC: .type(NewsVC.self))
        Router.shared.register(pattern: .kline, storedVC: .type(KLineVC.self))
    }
    
    var navigateActions: [NavigateActionModel] = {
        var actions = [NavigateActionModel]()
        
        actions.append(NavigateActionModel(name: "withoutAnimation", option: [.withoutAnimation]))
        actions.append(NavigateActionModel(name: "useStackNavigation", option: []))
        actions.append(NavigateActionModel(name: "wrapInNavigation", option: [.wrapInNavigation]))
        actions.append(NavigateActionModel(name: "dismissModal", option: [.dismissModal]))
        actions.append(NavigateActionModel(name: "withoutDismissalAnimation", option: [.withoutDismissalAnimation]))
        actions.append(NavigateActionModel(name: "ignoreLevel", option: [.ignoreLevel]))
        actions.append(NavigateActionModel(name: "popReplaceAnimation", option: [.popReplaceAnimation]))
        
        return actions
    }()
}

extension Router.Name {
    static let title = Self(url: "routerA://title")
    static let setting = Self(url: "routerA://general/setting")
    static let general = Self(url: "routerA://general")
    static let zone = Self(url: "routerA://general/zone")
    static let any = Self(url: "routerA://general/<AnyParams>")
    static let news = Self(url: "routerA://news")
    static let kline = Self(url: "routerA://kline")
}
