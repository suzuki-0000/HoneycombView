//
//  ThirdViewController.swift
//  HoneycombView
//
//  Created by suzuki_keishi on 7/1/15.
//  Copyright (c) 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import HoneycombView

struct User {
    var id:Int!
    var profileImageURL:String!

    init(id:Int = 0, profileImageURL:String = "image"){
        self.id = id
        self.profileImageURL = profileImageURL
    }
}

class ThirdViewController: UIViewController {
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<30{
            var user = User(id: i, profileImageURL: "https://placeimg.com/100/100/any")
            users.append(user)
        }
        
        let honeycombView = HoneycombView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        honeycombView.diameter = 200.0
        honeycombView.margin = 0.0
        honeycombView.configrationForHoneycombViewWithURL(users.map{ $0.profileImageURL })
        view.addSubview(honeycombView)
    }
}