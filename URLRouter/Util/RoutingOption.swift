//
//  RoutingOption.swift
//  URLRouter
//
//  Created by Michael Row on 2019/9/12.
//

public struct RoutingOption: OptionSet {
    
    public let rawValue: UInt
    
    /// 无跳转动画
    public static let withoutAnimation = RoutingOption(rawValue: 1 << 0)
    /// 使用就近导航栏控制器
    public static let useTopMostNavigation = RoutingOption(rawValue: 1 << 1)
    /// 包装在导航控制器中
    public static let wrapInNavigation = RoutingOption(rawValue: 1 << 2)
    /// 关闭所有模态页面
    public static let dismissModal = RoutingOption(rawValue: 1 << 3)
    /// 无模态关闭动画
    public static let withoutDismissalAnimation = RoutingOption(rawValue: 1 << 4)
    /// push下无视栈等级
    public static let ignoreLevel = RoutingOption(rawValue: 1 << 5)
    /// 页面出栈和替换有动画
    public static let popReplaceAnimation = RoutingOption(rawValue: 1 << 6)
    /// 全屏模态
    public static let fullScreenModal = RoutingOption(rawValue: 1 << 7)
    
    /// 压栈跳转，与present互斥
    public static let push = RoutingOption(rawValue: 1 << 10)
    /// 模态弹出，与push互斥
    public static let present = RoutingOption(rawValue: 1 << 11)
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
