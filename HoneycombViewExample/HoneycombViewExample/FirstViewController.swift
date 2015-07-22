//
//  FirstViewController.swift
//  HoneycombView
//
//  Created by 鈴木 啓司 on 6/30/15.
//  Copyright (c) 2015 鈴木 啓司. All rights reserved.
//

import UIKit
import HoneycombView

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        honeycombView.diameter = 40.0
        honeycombView.margin = 2.0
        honeycombView.configrationForHoneycombView()
        view.addSubview(honeycombView)
        
        honeycombView.animate(duration: 2.0)
    }
    
}

