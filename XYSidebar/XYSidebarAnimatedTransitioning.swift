//
//  XYSidebar.swift
//  XYSidebar
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

class XYSidebarAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 隐藏与否
    var isHidden: Bool = false
    
    var config:XYSidebarConfig!
    
    init(hiddeConfig: XYSidebarConfig, isHidden: Bool = false) {
        self.config = hiddeConfig
        self.isHidden = isHidden
    }
    
    // 执行的动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        config.timeInterval
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isHidden {
            animateTransitionHiddenType(transitionContext: transitionContext)
        } else {
            animateTransitionShowType(transitionContext: transitionContext)
        }
    }
    
    // show
    func animateTransitionShowType(transitionContext: UIViewControllerContextTransitioning) {
        let fromController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let width:CGFloat = XYSidebarConfig.screenWidth * config.sideRelative
        let x:CGFloat! = config.direction == .left ? 0.0 : (XYSidebarConfig.screenWidth - width)
        toController.view.frame = CGRect.init(x: x, y: 0, width: width, height: containerView.frame.height)
        toController.view.clipsToBounds = true
        // fromController UINavigationController
        // toController SnapKitViewController
        containerView.addSubview(toController.view)
        containerView.addSubview(fromController.view)
        
        var mask: XYSidebarMaskView?
        for view in toController.view.subviews where view is XYSidebarMaskView  {
            mask = view as? XYSidebarMaskView
        }
        if mask == nil {
            mask = XYSidebarMaskView()
            fromController.view.addSubview(mask!)
        }
        mask?.frame = fromController.view.bounds
        mask?.alpha = 0.0
        mask?.isUserInteractionEnabled = false
        
        let flag: CGFloat! = config.direction == .left ? -1.0 : 1.0
        
        var fromTransform: CGAffineTransform = CGAffineTransform(translationX: -flag * width, y: 0)
        let toTransform: CGAffineTransform = CGAffineTransform(translationX: flag * width, y: 0)
        
        if self.config.animation == .translationMask {
            fromTransform = CGAffineTransform(translationX: 0, y: 0)
            containerView.bringSubviewToFront(toController.view)
        }else if self.config.animation == .zoom {
            let t1: CGAffineTransform = CGAffineTransform(translationX: -flag * width * config.zoomOffsetRelative, y: 0)
            let t2: CGAffineTransform = CGAffineTransform(scaleX: config.zoomRelative, y: config.zoomRelative)
            fromTransform = t1.concatenating(t2)
        }
        if self.config.animation != .zoom {
            toController.view.transform = toTransform
            toController.view.frame = CGRect(x: toTransform.tx+x, y: 0, width: width, height: containerView.frame.height)
        }else {
            toController.view.transform = CGAffineTransform(translationX: 0, y: 0)
            toController.view.frame = CGRect(x: 0, y: 0, width: width, height: containerView.frame.height)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            mask?.alpha = self.config.maskAlpha
            toController.view.transform = .identity
            fromController.view.transform = fromTransform
        }) { (finished) in
            if !transitionContext.transitionWasCancelled {
                mask?.isUserInteractionEnabled = true
                transitionContext.completeTransition(true)
                containerView.addSubview(fromController.view)
                if self.config.animation == .translationMask {
                    containerView.bringSubviewToFront(toController.view)
                }
            }else {
                mask?.destroy()
                toController.view.transform = toTransform;
                fromController.view.frame = containerView.frame;
                transitionContext.completeTransition(false)
            }
        }
    }
    

    // hidde
    func animateTransitionHiddenType(transitionContext: UIViewControllerContextTransitioning) {
        let fromController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        let width:CGFloat = XYSidebarConfig.screenWidth * self.config.sideRelative
        let x:CGFloat! = config.direction == .left ? 0.0 : (XYSidebarConfig.screenWidth - width)
        
        fromController.view.frame = CGRect.init(x: x, y: 0, width: width, height: containerView.frame.height)
    
        var mask: XYSidebarMaskView?
        for view in toController.view.subviews {
            if view.isKind(of: XYSidebarMaskView.classForCoder()){
                mask = view as? XYSidebarMaskView
                break
            }
        }
        
        let flag: CGFloat! = config.direction == .left ? -1.0 : 1.0
        var fromTransform:CGAffineTransform = CGAffineTransform.init(translationX: flag * width, y: 0)
        
        if self.config.animation == .translationMask {
            fromTransform = CGAffineTransform.init(translationX: flag * width, y: 0)
        }else if self.config.animation == .zoom {
            fromTransform = CGAffineTransform.init(translationX: 0, y: 0)
            containerView.bringSubviewToFront(toController.view)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            mask?.alpha = 0.001
            fromController.view.transform = fromTransform
            toController.view.transform = .identity
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !transitionContext.transitionWasCancelled {
                mask?.destroy()
            }else {
                if self.config.animation != .zoom {
                    containerView.bringSubviewToFront(fromController.view)
                }
            }
        }
    }
    
    deinit {
//        print( NSStringFromClass(self.classForCoder) + " 销毁了---->4")
    }
}


