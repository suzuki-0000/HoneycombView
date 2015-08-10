//
//  FirstViewController.swift
//  HoneycombView
//
//  Created by suzuki_keishi on 6/30/15.
//  Copyright (c) 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import HoneycombView

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        honeycombView.diameter = 60.0
        honeycombView.margin = 1.0
        honeycombView.honeycombBackgroundColor = UIColor.orangeColor()
        honeycombView.configrationForHoneycombView()
        view.addSubview(honeycombView)
        
        honeycombView.animate(duration: 2.0)
    }
    
}

