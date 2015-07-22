//
//  SecondViewController.swift
//  HoneycombView
//
//  Created by 鈴木 啓司 on 7/1/15.
//  Copyright (c) 2015 鈴木 啓司. All rights reserved.
//

import UIKit
import HoneycombView

class SecondViewController: UIViewController {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<40{
            images.append(UIImage(named: "image\(i%10).jpg")!)
        }
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        honeycombView.diameter = 100.0
        honeycombView.margin = 1.0
        honeycombView.configrationForHoneycombViewWithImages(images)
        view.addSubview(honeycombView)
        
        honeycombView.animate()
    }
}