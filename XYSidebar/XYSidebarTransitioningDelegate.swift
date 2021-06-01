//
//  XYSidebarTransitioningDelegate.swift
//  XYSidebar
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

class XYSidebarTransitioningDelegate: NSObject,UIViewControllerTransitioningDelegate {
    
    var presentationInteractiveTransition: XYSidebarPercentInteractiveTransition?
    var dismissalInteractiveTransition: XYSidebarPercentInteractiveTransition!
    var config: XYSidebarConfig!
    
    init(_ config: XYSidebarConfig?) {
        self.config = config
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XYSidebarAnimatedTransitioning(hiddeConfig: config)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XYSidebarAnimatedTransitioning(hiddeConfig: config, isHidden: true)
    }
    
    // present交互的百分比
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print(animator)
        if presentationInteractiveTransition == nil {
            return nil
        }else {
            return (presentationInteractiveTransition?.isInteractive)! ? presentationInteractiveTransition : nil
        }
    }
    
    // dismiss交互的百分比
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissalInteractiveTransition.isInteractive ? dismissalInteractiveTransition : nil
    }
    
    deinit {

    }
    
}

