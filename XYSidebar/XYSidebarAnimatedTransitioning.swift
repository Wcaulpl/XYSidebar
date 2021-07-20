//
//  XYSidebar.swift
//  XYSidebar
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

class XYSidebarAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    // 隐藏与否
    var isPresent: Bool = true
    
    var config:XYSidebarConfig!
    
    init(_ config: XYSidebarConfig, isPresent: Bool = true) {
        self.config = config
        self.isPresent = isPresent
    }
    
    // 执行的动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        config.timeInterval
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            presentTransitionAnimation(transitionContext: transitionContext)
        } else {
            dismissTransitionAnimation(transitionContext: transitionContext)
        }
    }
    
    // show
    func presentTransitionAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = containerView.frame.width
        var height: CGFloat = containerView.frame.height

        switch config.direction {
        case .left:
            width *= config.sideRelative
        case .right:
            x = width * (1-config.sideRelative)
            width *= config.sideRelative
        case .bottom:
            y = height * (1-config.sideRelative)
            height *= config.sideRelative
        }
        
        toController.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
        toController.view.clipsToBounds = true

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
        
        let flagX: CGFloat = config.direction == .left ? -1.0 : config.direction == .right ? 1.0 : 0.0
        let flagY: CGFloat = config.direction == .bottom ? 1.0 : 0.0
        
        var fromTransform: CGAffineTransform = CGAffineTransform(translationX: -flagX * width, y: -flagY * height)
        if self.config.animation == .translationMask {
            fromTransform = CGAffineTransform(translationX: 0, y: 0)
            containerView.bringSubviewToFront(toController.view)
        } else if self.config.animation == .zoom {
            let transform1: CGAffineTransform = CGAffineTransform(translationX: -flagX * width * config.zoomOffsetRelative, y: -flagY * height * config.zoomOffsetRelative)
            let transform2: CGAffineTransform = CGAffineTransform(scaleX: config.zoomRelative, y: config.zoomRelative)
            fromTransform = transform1.concatenating(transform2)
        }
        
        let toTransform: CGAffineTransform = CGAffineTransform(translationX: flagX * width, y: flagY * height)
        if self.config.animation != .zoom {
            toController.view.transform = toTransform
            toController.view.frame = CGRect(x: toTransform.tx+x, y: toTransform.ty+y, width: width, height: height)
        } else {
            toController.view.transform = CGAffineTransform(translationX: 0, y: 0)
            toController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
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
    func dismissTransitionAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = containerView.frame.width
        var height: CGFloat = containerView.frame.height

        switch config.direction {
        case .left:
            width *= config.sideRelative
        case .right:
            x = width * (1-config.sideRelative)
            width *= config.sideRelative
        case .bottom:
            y = height * (1-config.sideRelative)
            height *= config.sideRelative
        }
        
        fromController.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
    
        var mask: XYSidebarMaskView?
        for view in toController.view.subviews {
            if view.isKind(of: XYSidebarMaskView.classForCoder()){
                mask = view as? XYSidebarMaskView
                break
            }
        }
        let flagX: CGFloat = config.direction == .left ? -1.0 : config.direction == .right ? 1.0 : 0.0
        let flagY: CGFloat = config.direction == .bottom ? 1.0 : 0.0
        
        var fromTransform: CGAffineTransform = CGAffineTransform(translationX: flagX * width, y: flagY * height)
        
        if config.animation == .zoom {
            fromTransform = CGAffineTransform(translationX: 0, y: 0)
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


