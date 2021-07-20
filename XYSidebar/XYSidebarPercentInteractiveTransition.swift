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
    private var config: XYSidebarConfig!
//    private var isHidden: Bool = false
    private var direction: XYSidebarDirection = .left
    private var percent:CGFloat  = 0.0 //必须用全局的
    
    static func present() -> XYSidebarPercentInteractiveTransition {
        return XYSidebarPercentInteractiveTransition(nil, config: nil)
    }
    
    static func dismss(_ viewController: UIViewController?, config:XYSidebarConfig?) -> XYSidebarPercentInteractiveTransition {
        return XYSidebarPercentInteractiveTransition(viewController, config: config)
    }
    
    init(_ viewController: UIViewController?, config:XYSidebarConfig?) {
        super.init()
        self.targetVc = viewController
        self.config = config
        NotificationCenter.default.addObserver(self, selector: #selector(xy_tapAction), name: NSNotification.Name(rawValue:XYSidebarTapNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(xy_panAction(_ :)), name: NSNotification.Name(rawValue:XYSidebarPanNotification), object: nil)
    }
    
    @objc func xy_tapAction() {
        if let vc = targetVc {
            vc.dismiss(animated: true, completion: nil)
            finish()
        }
    }
    
    @objc func xy_panAction(_ sender:Notification) {
        if let _ = config {
            let pan:UIPanGestureRecognizer = sender.object as! UIPanGestureRecognizer
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
                direction = .right
            } else if x >= 0 {
                direction = .left
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
        if config == nil {
            handlePresentPan(pan: pan)
            return
        }
        
        var x:CGFloat = pan.translation(in: pan.view).x // -左划 +右滑
        var width:CGFloat = (pan.view!.bounds.width) // 手势驱动时 相对移动的宽度

        if config.direction == .bottom {
            x = pan.translation(in: pan.view).y // -上划 +下滑
            width = pan.view!.bounds.height
        }
        
        if config.animation == .zoom {
            width = width * (1.0 - config.zoomOffsetRelative)
        }
        
        var percent:CGFloat = 0.0
        switch pan.state {
        case .began :
            isInteractive = true
            targetVc?.dismiss(animated: true, completion: nil)
            break;
        case .changed:
            if config.direction == .left {
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
            
            if gestureRecognizer.location(in: gestureRecognizer.view).x > gestureRecognizer.view!.frame.width - 30 {
                return true
            }
            
            if gestureRecognizer.location(in: gestureRecognizer.view).y > gestureRecognizer.view!.frame.height - 30 {
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
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
