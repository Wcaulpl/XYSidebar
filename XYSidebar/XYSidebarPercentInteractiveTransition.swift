//
//  XYSidebarPercentInteractiveTransition.swift
//  GYSideDemo
//
//  Created by MacPro on 2021/5/10.
//

import UIKit

typealias completeShowGestureTask = (XYSidebarDirection) -> ()

class XYSidebarPercentInteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    var completeShowGesture: ((XYSidebarDirection)->())?
    
    var isInteractive:Bool = false
    
    weak var targetVc: UIViewController!
    var config: XYSidebarConfig!
    var isHidden: Bool = false
    private var direction: XYSidebarDirection = .left
    private var percent:CGFloat  = 0.0 //必须用全局的
    
    static func show(viewController: UIViewController?, config:XYSidebarConfig?) -> XYSidebarPercentInteractiveTransition {
        let transition = XYSidebarPercentInteractiveTransition()
        transition.targetVc = viewController
        transition.config = config
        NotificationCenter.default.addObserver(transition, selector: #selector(xy_tapAction), name: NSNotification.Name(rawValue:XYSidebarTapNotification), object: nil)
        NotificationCenter.default.addObserver(transition, selector: #selector(xy_panAction(_ :)), name: NSNotification.Name(rawValue:XYSidebarPanNotification), object: nil)
        return transition
    }
    
    static func hidden(viewController: UIViewController?, config:XYSidebarConfig?) -> XYSidebarPercentInteractiveTransition {
        let transition = XYSidebarPercentInteractiveTransition()
        transition.targetVc = viewController
        transition.config = config
        transition.isHidden = true
        NotificationCenter.default.addObserver(transition, selector: #selector(xy_tapAction), name: NSNotification.Name(rawValue:XYSidebarTapNotification), object: nil)
        NotificationCenter.default.addObserver(transition , selector: #selector(xy_panAction(_ :)), name: NSNotification.Name(rawValue:XYSidebarPanNotification), object: nil)
        return transition
    }
    
    @objc func xy_tapAction() {
        if !isHidden {return}
        targetVc?.dismiss(animated: true, completion: nil)
        finish()
    }
    
    @objc func xy_panAction(_ sender:Notification) {
        let pan:UIPanGestureRecognizer = sender.object as! UIPanGestureRecognizer
        if isHidden {
            handlePan(pan: pan)
        }
    }
    
    func addPanGesture(fromViewController:UIViewController) {
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(pan:)))
        pan.delegate = self
        fromViewController.view.addGestureRecognizer(pan)
    }
    
    //手势blcok 回调
    func handlePresentPan(pan:UIPanGestureRecognizer) {
        var x:CGFloat = pan.translation(in: pan.view).x // -左划 +右滑
        let width:CGFloat = (pan.view!.bounds.width)
        var percent:CGFloat = 0.0
        
        switch pan.state {
        case .began:
            if x < 0 {
                direction = .right;
            } else if x >= 0 {
                direction = .left;
            }
            isInteractive = true
            if let block = completeShowGesture {
                block(direction)
            }
            break
        case .changed:
            if direction == .right {
                x = x > 0.0 ? 0.0 : x
            } else {
                x = x < 0.0 ? 0.0 : x
            }
            percent = CGFloat(fabsf(Float(x/width)))
            percent = percent<=0.0 ? 0.0:percent
            percent = percent>=1.0 ? 1.0:percent
            self.percent = percent
            self.update(percent)
            break
        case .ended:
            isInteractive = false
            if self.percent < 0.5 {
                cancel()
            } else {
                finish()
            }
            break
        case .cancelled:
            isInteractive = false
            cancel()
            break
        default:
            break
        }
    }
    
    @objc func handlePan(pan: UIPanGestureRecognizer)  {
        var x:CGFloat = pan.translation(in: pan.view).x // -左划 +右滑
        if config == nil && !isHidden {
            handlePresentPan(pan: pan)
            return
        }
        var width:CGFloat = (pan.view!.bounds.width) // 手势驱动时 相对移动的宽度
        if config.animation == .zoom {
            width = XYSidebarConfig.screenWidth * (1.0 - config.zoomOffsetRelative)
        }
        var percent:CGFloat = 0.0
        switch pan.state {
        case .began :
            isInteractive = true
            targetVc?.dismiss(animated: true, completion: nil)
            break;
        case .changed:
            if config.direction == .left && isHidden {
                x = x>0.0 ? 0.0:x
            }else {
                x = x<0.0 ? 0.0:x
            }
            percent = CGFloat(fabsf(Float(x/width)))
            percent = percent<=0.0 ? 0.0:percent
            percent = percent>=1.0 ? 1.0:percent
            self.percent = percent
            update(percent)
            break
        case .ended:
            isInteractive = false
            if self.percent < 0.5 {
                cancel()
            } else {
                finish()
            }
            break
        case .cancelled:
            isInteractive = false
            cancel()
            break
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if XYSidebar.navigationController?.children.count ?? 0 == 1 {
            if gestureRecognizer.location(in: gestureRecognizer.view).x < 30 {
                return true
            }
        }
        
        
        return false
    }
    
    //返回true，则表示两个手势同时使用
    //否则仅最新添加的生效
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if XYSidebar.navigationController?.children.count ?? 0 == 1 {
            if let scrollView = otherGestureRecognizer.view as? UIScrollView {
                let translation = scrollView.panGestureRecognizer.translation(in: scrollView)
                if scrollView.contentOffset.x == 0 && translation.x > 0 && translation.y == 0 {
                    return true;
                }
            }
        }
        
        
        
//        if XYSidebar.navigationController?.children.count ?? 0 == 1 && otherGestureRecognizer != XYSidebar.navigationController?.interactivePopGestureRecognizer && !(otherGestureRecognizer.view is XYSidebarMaskView) {
//            return true
//        }
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
