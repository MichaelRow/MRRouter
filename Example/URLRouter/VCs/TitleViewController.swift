//
//  TitleViewController.swift
//  URLRouter_Example
//
//  Created by Michael Row on 2019/9/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import URLRouter

class TitleViewController: UIViewController, RoutableViewController {
    
    class var stackLevel: StackLevel { return .lowest }
    
    required convenience init(_ parameters: [String : Any]) {
        self.init()
    }
    
    func viewControllerWillUpdateParameters(by navigator: Navigator, context: RoutingContext) {}
    
    func viewControllerDidUpdateParameters(by navigator: Navigator, context: RoutingContext) {}
    
    lazy var parameters = [String : Any]()
        
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var label: UILabel?
    
    init() {
        super.init(nibName: "TitleViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label?.text = "\(type(of: self))"
        textView?.text = parameters.description
    }
}
