//
//  XYSidebarConfig.swift
//  XYSidebar
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

var showControlelrTransitioningDelegateKey = "showControlelrTransitioningDelegateKey"
let XYSidebarTapNotification = "sidebarTapNotification"
let XYSidebarPanNotification = "sidebarPanNotification"

public enum XYSidebarAnimation:Int {
    case zoom //缩放
    case translationPush //横向平移
    case translationMask //盖在最上面横向平移
}

public enum XYSidebarDirection:Int {
    case left  // 从左边出来
    case right // 从右边出来
}

public class XYSidebarConfig {
    static let screenWidth = UIScreen.main.bounds.width

    /// 执行动画的时长 默认0.3
    public var timeInterval: TimeInterval = 0.3
    
    /// 遮罩视图的透明度 默认0.5
    public var maskAlpha: CGFloat = 0.5
    
    /// 侧边栏相对屏幕宽度比例 0.0 ~ 1.0  默认0.7
    public var sideRelative: CGFloat = 0.7 {
        didSet {
            if sideRelative>1.0 {sideRelative = 1.0}
            if sideRelative<0.0 {sideRelative = 0.0}
            if animation == .zoom  {sideRelative = 1.0}
        }
    }
    
    /// 缩放模式时缩放的比例 0.0 ~ 1.0  默认0.7
    public var zoomRelative: CGFloat! = 0.7 {
        didSet {
            if zoomRelative>1.0 {zoomRelative = 1.0}
            if zoomRelative<0.0 {zoomRelative = 0.0}
        }
    }
    
    /// 缩放模式时 缩放控制器的view偏移的距离 相对屏幕宽度比例 0.0 ~ 1.0  默认0.5
    public var zoomOffsetRelative: CGFloat! = 0.5 {
        didSet {
            if zoomOffsetRelative>1.0 {zoomOffsetRelative = 1.0}
            if zoomOffsetRelative<0.0 {zoomOffsetRelative = 0.0}
        }
    }
    
    /// 侧边来出来的的方向 默认从左边出来
    public var direction: XYSidebarDirection = .left
    
    /// 侧边来出来的动画方式
    public var animation: XYSidebarAnimation = .translationPush {
        didSet {
            if animation == .zoom  {sideRelative = 1.0}
        }
    }
    
    deinit {

    }
    
    
}

