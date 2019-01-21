//
//  ViewController.swift
//  GRCycleScrollView
//
//  Created by john.lin on 2019/1/21.
//  Copyright © 2019年 john.lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cycleView: GRCycleScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCycleView()
    }
    func setupCycleView() {
        let images: [String] = ["iconCheck", "iconDiamond", "iconStar"]
        
        cycleView = GRCycleScrollView(frame: CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 120))
        self.cycleView?.imagePaths = images
        self.cycleView?.duration = 5.0
        self.cycleView?.coverImage = UIImage(named: "iconCheck")
        self.cycleView?.delegate = self
        self.view.addSubview(cycleView!)
    }

}

extension ViewController: GRCycleScrollViewDelegate {
    func cycleViewDidSelectedIndex(_ index: Int) {
        print(index)
    }
}
