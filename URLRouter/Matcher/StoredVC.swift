//
//  StoredVC.swift
//  URLRouter
//
//  Created by Michael Row on 2019/12/1.
//

public enum StoredVC {
    /// 使用类型构造VC，VC必须支持通过init()初始化
    case type(_ type: UIViewController.Type)
    /// 使用closure构造VC，并提供准确的VC类型。
    ///
    /// 在constructor初始化VC后会进行校验，crash if not match.
    case constructor(_ constructor: (_ params: [String : Any]?) -> UIViewController, _ type: UIViewController.Type)
    
    var stackLevel: StackLevel? {
        switch self {
        case .type(let type):
            return type.routable?.stackLevel
        case .constructor(_, let type):
            return type.routable?.stackLevel
        }
    }
    
    func instantiatedViewController(for params: [String : Any]? = nil) -> UIViewController {
        switch self {
        case .type(let type):
            return type.init()
        case .constructor(let constructor, let type):
            let VC = constructor(params)
            guard Swift.type(of: VC) == type else {
                fatalError(".constructor(_,_)创建的VC类型不匹配")
            }
            return VC
        }
    }
    
    /// 获得存储在枚举中的VC类型
    var viewControllerType: UIViewController.Type {
        switch self {
        case .type(let type):
            return type
        case .constructor(_, let type):
            return type
        }
    }
}
