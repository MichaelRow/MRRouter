//
//  RouterError.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/9.
//

public enum RouterError: String, Error {
    case noAction = "无可执行的跳转操作"
    case noRouting = "无跳转路径"
    case noNavigationController = "没用可用于push的NavigationController"
    case essitialCheckFail = "缺少用于初始化新VC的类型或缺少NavigationController"
    case tabBarControllerError = "需跳转的TabBar下标不合法或当前Tab没有可以push的NavigationController"
    case resolveFailed = "参数解析失败"
    case asyncResolveFailed = "异步参数解析失败"
    case rejectNavigate = "当前显示的VC拒绝跳转"
    case instantiateVCFailed = "无法初始化需要跳转的VC"
    case getTopMostVCFailed = "无法获取最上层的VC"
    case noStackPopDestinationIndex = "没有需要弹栈的下标"
    case noVCInStack = "没有VC在NavigationController的页面栈中"
}
