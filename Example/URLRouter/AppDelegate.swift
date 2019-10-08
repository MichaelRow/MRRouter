//
//  AppDelegate.swift
//  URLRouter
//
//  Created by MichaelRow on 09/05/2019.
//  Copyright (c) 2019 MichaelRow. All rights reserved.
//

import UIKit

var sharedDebugMapper: DebugMapper!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var debugWindow: UIWindow?
    
    var naviVC: UINavigationController = {
        let navi = UINavigationController(rootViewController: TitleViewController())
        navi.navigationBar.isTranslucent = false
        return navi
    }()
    
    var tabBarVC: UITabBarController = {
        let tabbarVC = UITabBarController()
        var navis = [UINavigationController]()
        for index in 0 ..< 5 {
            let navi = UINavigationController(rootViewController: TitleViewController())
            navi.navigationBar.isTranslucent = false
            navi.tabBarItem = UITabBarItem(title: "Tab \(index)", image: nil, selectedImage: nil)
            navis.append(navi)
        }
        tabbarVC.viewControllers = navis
        return tabbarVC
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.rootViewController = naviVC
        window.makeKeyAndVisible()
        self.window = window
        
        sharedDebugMapper = DebugMapper(naviVC: naviVC, tabBarVC: tabBarVC, on: window)
        
        debugWindow = DebugWindow(frame: UIScreen.main.bounds)
        debugWindow?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchAppearance(_:)), name: Notification.Name("SwitchAppearance"), object: nil)
        
        return true
    }
    
    @objc func switchAppearance(_ n: Notification) {
        sharedDebugMapper.switchRouter()
        guard let rootVC = window?.rootViewController else { return }
        if rootVC.isKind(of: UINavigationController.self) {
            window?.rootViewController = tabBarVC
        } else {
            window?.rootViewController = naviVC
        }
    }
}

