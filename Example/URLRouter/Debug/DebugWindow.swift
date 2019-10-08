//
//  DebugWindow.swift
//  URLRouter_Example
//
//  Created by Michael on 2019/9/29.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class DebugWindow: UIWindow {

    var consoleView: DebugConsoleView = {
        return DebugConsoleView(frame: CGRect(x: 0, y: 88, width: screenWidth, height: 242))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = UIViewController()
        rootViewController?.view.backgroundColor = .clear
        initializeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeUI()
    }
    
    private func initializeUI() {
        windowLevel = .statusBar
        self.rootViewController?.view.addSubview(consoleView)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return consoleView.shouldHandleEvent(point, from: self)
    }
}
