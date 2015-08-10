//
//  SecondViewController.swift
//  HoneycombView
//
//  Created bysuzuki_keishi on 7/1/15.
//  Copyright (c) 2015suzuki_keishi. All rights reserved.
//

import UIKit
import HoneycombView

class SecondViewController: UIViewController {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<50{
            images.append(UIImage(named: "image\(i%10).jpg")!)
        }
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height/2))
        honeycombView.center = CGPointMake(view.frame.width/2, view.frame.height/2)
        honeycombView.diameter = 100.0
        honeycombView.margin = 1.0
        honeycombView.configrationForHoneycombViewWithImages(images)
        view.addSubview(honeycombView)
        
        honeycombView.animate(duration: 0.5)
    }
}