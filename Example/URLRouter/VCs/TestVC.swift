//
//  TestVC.swift
//  URLRouter_Example
//
//  Created by Michael on 2019/9/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import URLRouter

class FriendVC: TitleViewController {
    override class var stackLevel: StackLevel { return .lowest }
}

class SettingVC: TitleViewController {
    override class var stackLevel: StackLevel { return .low }
}

class NewsVC: TitleViewController {
    override class var stackLevel: StackLevel { return .medium }
}

class KLineVC: TitleViewController {
    override class var stackLevel: StackLevel { return .high }
}

class PortfolioVC: TitleViewController {
    override class var stackLevel: StackLevel { return .highest }
}

class AnyParamsVC: TitleViewController {
    override class var stackLevel: StackLevel { return .medium }
}

class ZoneVC: TitleViewController {
    override class var stackLevel: StackLevel { return .lowest }
}

class GeneralVC: TitleViewController {
    override class var stackLevel: StackLevel { return .high }
}
