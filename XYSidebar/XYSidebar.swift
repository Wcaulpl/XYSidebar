//
//  XYSidebarMaskView.swift
//  XYSidebar
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

class XYSidebar {
    /// keyWindowd
    static var keyWindow: UIWindow {
        get {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                if let mainWindow = windowScene?.value(forKeyPath: "delegate.window") {
                    return mainWindow as! UIWindow
                }
                return UIApplication.shared.windows.last!
            } else {
                if let keyWindow = UIApplication.shared.delegate?.window {
                    return keyWindow!
                }
                return UIApplication.shared.keyWindow!
            }
        }
    }
    
    static var navigationController: UINavigationController? {
        get {
            let rootVc: UIViewController = keyWindow.rootViewController!
            if rootVc is UITabBarController {
                let tabBar: UITabBarController = rootVc as! UITabBarController
                return tabBar.selectedViewController as? UINavigationController
            } else if rootVc is UINavigationController {
                return rootVc as? UINavigationController
            }
            return nil
        }
    }
}

extension UIViewController {
    
    /// 侧边栏出来
    ///
    /// - Parameters:
    ///   - configuration: 配置
    ///   - viewController: 将要展现的viewController
    public func xy_present(_ configuration:(XYSidebarConfig)->(), _ viewController:UIViewController) {
        
        let config = XYSidebarConfig()
        configuration(config)
        
        var delegate = objc_getAssociatedObject(self, &showControlelrTransitioningDelegateKey) as? XYSidebarTransitioningDelegate
        if delegate == nil {
            delegate = XYSidebarTransitioningDelegate(config)
            objc_setAssociatedObject(viewController, &showControlelrTransitioningDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            delegate!.config = config
        }
        // 添加手势返回
        let dismissalInteractiveTransition = XYSidebarPercentInteractiveTransition.dismss(viewController, config: config)
        delegate!.dismissalInteractiveTransition = dismissalInteractiveTransition
        viewController.transitioningDelegate = delegate 
        viewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { //防止present延迟
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    /// 让侧边栏支持手势拖拽出来
    ///
    /// - Parameter completeShowGesture: 侧边栏展示的方向
    public func xy_registGestureSidebar(completeShowGesture:@escaping (XYSidebarDirection)->()) {
        let delegate = XYSidebarTransitioningDelegate(nil)
        let presentationInteractiveTransition = XYSidebarPercentInteractiveTransition.present()
        presentationInteractiveTransition.addPanGesture(fromViewController: self)
        presentationInteractiveTransition.completeShowGesture = completeShowGesture
        delegate.presentationInteractiveTransition = presentationInteractiveTransition
        
        self.transitioningDelegate = delegate
        objc_setAssociatedObject(self, &showControlelrTransitioningDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 侧边栏调用push
    ///
    /// - Parameter viewController
    public func xy_sidebarPushViewController(_ viewController: UIViewController) {
        let rootVc: UIViewController = XYSidebar.keyWindow.rootViewController!
        if rootVc is UITabBarController {
            viewController.hidesBottomBarWhenPushed = true
        }
        self.dismiss(animated: true, completion: nil)
        XYSidebar.navigationController?.pushViewController(viewController, animated: false)
    }
        
    /// 侧边栏调用present
    ///
    /// - Parameter viewController
    public func xy_sidebarPresentViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        let rootVc: UIViewController = XYSidebar.keyWindow.rootViewController!
        if ((rootVc.presentedViewController) != nil) {
            rootVc.presentedViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    rootVc.present(viewController, animated: true, completion: nil)
                }
            })
        }
    }
    
}

final class XYSidebarMaskView: UIVisualEffectView {

    init() {
        super.init(effect: UIBlurEffect.init(style: .dark))
        //初始准备代码
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_ :)))
        self.addGestureRecognizer(tap)
        
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(_ :)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func tapAction(_ sender:UITapGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XYSidebarTapNotification), object: nil)
    }
    
    @objc private func panAction(_ sender:UITapGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XYSidebarPanNotification), object: sender)
    }
    
    func destroy() {
        self.removeFromSuperview()
    }
    
    deinit {

    }
}
