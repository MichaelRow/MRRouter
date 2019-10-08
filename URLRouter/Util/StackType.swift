//
//  StackType.swift
//  URLRouter
//
//  Created by Michael on 2019/9/27.
//

public enum StackType: String {
    /// 无操作
    case doNothing
    /// 添加新的VC
    case push
    /// 替换最上层VC
    case replace
    /// 移除部分低优先级的VC并插入VC
    case popThenInsert
    /// 移除部分优先级的VC并替换移除后的栈顶VC
    case popThenReplace
    /// 刷新当前VC的参数
    case refreshParameters
    /// 移除部分低优先级的VC并刷新最上层VC参数
    case popThenRefreshParameters
    
    public var shouldInitVC: Bool {
        switch self {
        case .doNothing, .refreshParameters, .popThenRefreshParameters:
            return false
        default:
            return true
        }
    }
}
