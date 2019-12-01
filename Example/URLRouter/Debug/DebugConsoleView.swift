//
//  DebugConsoleView.swift
//  URLRouter_Example
//
//  Created by Michael on 2019/9/29.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import URLRouter

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let gap: CGFloat = 16
let reuseID = "OptionCell"

class DebugConsoleView: UIView {
    
    lazy var components = [UIView]()
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: gap, y: gap, width: screenWidth - 3 * gap - 60, height: 34))
        textField.borderStyle = .roundedRect
        textField.placeholder = "URL"
        return textField
    }()
    
    lazy var tabTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: screenWidth - gap - 60, y: gap, width: 60, height: 34))
        textField.borderStyle = .roundedRect
        textField.placeholder = "Tab"
        return textField
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect(x: gap, y: 2 * gap + 34, width: screenWidth - 2 * gap, height: 120))
        tv.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tv.allowsMultipleSelection = true
        tv.isEditing = true
        tv.allowsMultipleSelectionDuringEditing = true
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    lazy var pushBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: screenWidth - gap - 70, y: 3 * gap + 154, width: 70, height: 30))
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .gray
        btn.setTitle("Push", for: .normal)
        btn.addTarget(self, action: #selector(pushAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var presentBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: screenWidth - 2 * gap - 2 * 70, y: 3 * gap + 154, width: 70, height: 30))
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .gray
        btn.setTitle("Present", for: .normal)
        btn.addTarget(self, action: #selector(presentAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var switchBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: screenWidth - 3 * gap - 3 * 70, y: 3 * gap + 154, width: 70, height: 30))
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.setTitle("Switch", for: .normal)
        btn.addTarget(self, action: #selector(switchAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = UIColor.clear
        alpha = 0.5
        
        components.append(contentsOf: [textField,pushBtn,presentBtn,tableView,switchBtn,tabTextField])
        components.forEach { control in
            addSubview(control)
        }
        tableView.reloadData()
    }
    
    func shouldHandleEvent(_ point: CGPoint, from window: UIWindow) -> Bool {
        for control in components {
            if control.bounds.contains(control.convert(point, from: window)) {
                return true
            }
        }
        return false
    }
    
    func optionInTableView() -> RoutingOption {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return [] }
        var option = RoutingOption()
        for row in selectedRows {
            option.insert(DebugMapper.shared.navigateActions[row.row].option)
        }
        return option
    }
    
    //MARK: - Action
    
    @objc func pushAction(_ sender: UIButton) {
        guard let url = textField.text else { return }
        let tabIndex = Int(tabTextField.text ?? "")
        let openType: TabBarOpenType = tabIndex == nil ? .current : .custom(tabIndex!)
        Router.shared.push(pattern: .init(url: url), parameters: [:], option: optionInTableView(), tabBarOpenType: openType, completion: nil)
    }
    
    @objc func presentAction(_ sender: UIButton) {
        guard let url = textField.text else { return }
        let tabIndex = Int(tabTextField.text ?? "")
        let openType: TabBarOpenType = tabIndex == nil ? .current : .custom(tabIndex!)
        Router.shared.present(pattern: .init(url: url), parameters: [:], option: optionInTableView(), tabBarOpenType: openType, completion: nil)
    }
    
    @objc func switchAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwitchAppearance"), object: nil, userInfo: nil)
    }
}

extension DebugConsoleView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension DebugConsoleView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DebugMapper.shared.navigateActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseID)
        guard indexPath.row < DebugMapper.shared.navigateActions.count else { return cell }
        cell.textLabel?.text = DebugMapper.shared.navigateActions[indexPath.row].name
        return cell
    }
}
