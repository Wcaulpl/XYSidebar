//
//  ViewController.swift
//  XYSidebarDemo
//
//  Created by MacPro on 2021/5/27.
//

import UIKit


class SideController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let btn = UIButton(type: .custom)
        btn.setTitle("next", for: .normal)
        view.addSubview(btn)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn.addTarget(self, action: #selector(nextVc), for: .touchUpInside)
    }

    @objc func nextVc() {
        xy_sidebarPushViewController(UIViewController())
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        xy_registGestureSidebar { [weak self] direction in
            if direction == .bottom {
                self?.showLeftSide()
            } else if direction == .left {
                self?.showLeftSide()
            } else if direction == .right {
                self?.showLeftSide()
            }
        }
    }

    func showLeftSide() {
        let vc = SideController()
        xy_present({ [unowned self] in
            $0.sideRelative = 0.84
            $0.direction = direction
            $0.animation = animation

        }, vc)
    }

    @IBAction func next() {
        showLeftSide()
    }
    
    var direction: XYSidebarDirection = .left
    var animation: XYSidebarAnimation = .translationPush
    
    @IBAction func left(_ btn: UIButton) {
        for tag in 10...12 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        direction = .left
    }
    
    @IBAction func right(_ btn: UIButton) {
        for tag in 10...12 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        direction = .right
    }
    
    @IBAction func bottom(_ btn: UIButton) {
        for tag in 10...12 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        direction = .bottom
    }
    
    @IBAction func zoom(_ btn: UIButton) {
        for tag in 20...22 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        animation = .zoom
    }
    
    @IBAction func push(_ btn: UIButton) {
        for tag in 20...22 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        animation = .translationPush
    }
    
    @IBAction func mask(_ btn: UIButton) {
        for tag in 20...22 {
            if let temp = view.viewWithTag(tag) as? UIButton {
                temp.isSelected = false
            }
        }
        btn.isSelected = true
        animation = .translationMask
    }
}

