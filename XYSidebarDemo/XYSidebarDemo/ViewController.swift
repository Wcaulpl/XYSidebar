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
            if direction == .left {
                self?.showLeftSide()
            }
        }
    }

    func showLeftSide() {
        let vc = SideController()
        xy_showSidebar({
            $0.sideRelative = 0.84
        }, vc)
    }

    @IBAction func next() {
        showLeftSide()
    }
}

