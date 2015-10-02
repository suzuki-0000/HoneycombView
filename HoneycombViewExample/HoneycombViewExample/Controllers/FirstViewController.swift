//
//  FirstViewController.swift
//  HoneycombView
//
//  Created by suzuki_keishi on 6/30/15.
//  Copyright (c) 2015 suzuki_keishi. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController{
    
    var images = [UIImage]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<30{
            images.append(UIImage(named: "image\(i%10).jpg")!)
        }
        
        for i in 0..<30{
            let user = User(id: i, profileImageURL: "https://placehold.jp/150x150.png")
            users.append(user)
        }
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height/1.5))
        honeycombView.center = CGPointMake(view.frame.width/2, view.frame.height/2)
        honeycombView.diameter = 200.0
        honeycombView.margin = 1.0
        honeycombView.configrationForHoneycombViewWithImages(images)
        //honeycombView.configrationForHoneycombViewWithURL(users.map{ $0.profileImageURL })
        view.addSubview(honeycombView)
        
        honeycombView.animate(2.0)
        
    }
}


struct User {
    var id:Int!
    var profileImageURL:String!
    
    init(id:Int = 0, profileImageURL:String = "image"){
        self.id = id
        self.profileImageURL = profileImageURL
    }
}
