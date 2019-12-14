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
    
    lazy var parameters = [String : Any]()
    
    class var stackLevel: StackLevel { return .lowest }
    
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var label: UILabel?
    
    init() {
        super.init(nibName: "TitleViewController", bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
