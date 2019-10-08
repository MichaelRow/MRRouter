//
//  UIViewController+Routable.swift
//  URLRouter
//
//  Created by Michael on 2019/9/23.
//

import UIKit

public extension UIViewController {
    
    class var routable: RoutableViewController.Type? {
        return self as? RoutableViewController.Type
    }
    
    var routable: RoutableViewController? {
        return self as? RoutableViewController
    }
}
