//
//  FirstViewController.swift
//  HoneycombView
//
//  Created by suzuki_keishi on 6/30/15.
//  Copyright (c) 2015 suzuki_keishi. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<50{
            images.append(UIImage(named: "image\(i%10).jpg")!)
        }
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        honeycombView.center = CGPointMake(view.frame.width/2, view.frame.height/2)
        honeycombView.diameter = 160.0
        honeycombView.margin = 1.0
        honeycombView.configrationForHoneycombViewWithImages(images)
        view.addSubview(honeycombView)
        
        honeycombView.animate(2.0)
    }
    
}

