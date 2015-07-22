//
//  HoneycombView.swift
//  HoneycombView
//
//  Created by 鈴木 啓司 on 7/1/15.
//  Copyright (c) 2015 鈴木 啓司. All rights reserved.
//

import UIKit

public enum HoneycombAnimateType { case FadeIn }

public class HoneycombView: UIView{
    
    public var animateType:HoneycombAnimateType = .FadeIn
    
    public var diameter:CGFloat = 100
    public var margin:CGFloat = 10
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    public func configrationForHoneycombView(){
        // setup layout
        let structure = constructView()
        
        // set view
        for point in structure {
            let honeycombImageView = HoneycombImageView(frame: CGRectMake(0, 0, diameter, diameter))
            honeycombImageView.center = point
            addSubview(honeycombImageView)
        }
    }
    
    public func configrationForHoneycombViewWithImages(images:[UIImage]){
        // setup layout
        let structure = constructView()
        
        // set view
        for (index, element)in enumerate(structure){
            let honeycombImageView = HoneycombImageView(frame: CGRectMake(0, 0, diameter, diameter))
            honeycombImageView.center = element
            // set image if images have
            if images.count > index {
                honeycombImageView.image = images[index]
            }
            addSubview(honeycombImageView)
        }
 
    }
    
    public func configrationForHoneycombViewWithURL(urls:[String]){
        // setup struture
        let structure = constructView()
        
        // add to view
        for (index, element)in enumerate(structure){
            let honeycombImageView = HoneycombImageView(frame: CGRectMake(0, 0, diameter, diameter))
            honeycombImageView.center = element
            if urls.count > index {
               let imgURL: NSURL = NSURL(string: urls[index])!
               let request: NSURLRequest = NSURLRequest(URL: imgURL)
               NSURLConnection.sendAsynchronousRequest(
                    request, queue: NSOperationQueue.mainQueue(),
                    completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        honeycombImageView.image = UIImage(data: data)
                    }
                })
            }
            addSubview(honeycombImageView)
        }
    }
    
    private func constructView() -> [CGPoint]{
        var structure = [CGPoint]()
        
        // static name of 'side'
        let side = (buttom: 0, left: 1, upper: 2, right: 3)
        // calculate center point
        let centerPoint = CGPointMake(frame.size.width/2, frame.size.height/2)
        // calculate user radius include magin
        let radius =  (diameter + margin) / 2.0
        // calculate size of x and y. y is for shifting location a half
        let interval = CGSizeMake(radius * 2.0, radius * 2.0 - (diameter/4))
        
        let layerCount = Int(ceil(frame.height/max(interval.width, interval.height)))
        
        // configure view point
        for layerId in 0..<layerCount{
            // if layer is first of point
            if layerId == 0{
                structure.append(centerPoint)
                continue
            }
            
            // count in side
            let countInSide = layerId * 2
            for sideId in 0..<4 {
                // direction of x, y
                var (dx:Int, dy:Int) = (0, 0)
                // point x, y from center point
                var (a:Int, b:Int) = (layerId, layerId)
                
                // set direction and point from center
                switch sideId {
                case side.buttom:
                    (dx, dy) = (-1, 0)
                    (a,   b) = (layerId, layerId)
                case side.left:
                    (dx, dy) = (0, -1)
                    (a,   b) = (-layerId, layerId)
                case side.upper:
                    (dx, dy) = (1, 0)
                    (a,   b) = (-layerId, -layerId)
                case side.right:
                    (dx, dy) = (0, 1)
                    (a,   b) = (layerId, -layerId)
                default: break
                }
                
                // forward next point of side
                for indexInSide in 0..<countInSide {
                    let x = a + dx * indexInSide
                    let y = b + dy * indexInSide
                    
                    var (pointX:CGFloat, pointY:CGFloat) = (0, 0)
                    // go forward a half when odd
                    if(y % 2 == 0) {
                        pointX = centerPoint.x + interval.width * CGFloat(x)
                    } else {
                        pointX = centerPoint.x + interval.width * (CGFloat(x) + 0.5)
                    }
                    pointY = centerPoint.y + interval.height * CGFloat(y)
                    
                    structure.append(CGPointMake(pointX, pointY))
                }
            }
        }
        return structure
    }
    
    
    public func animate(){
        animate(duration:2.0)
    }
    
    public func animate(#duration: Double){
        animate(duration:duration, delay:0.0)
    }
    
    public func animate(#duration: Double, delay: Double){
        for honeycombView in subviews {
            if honeycombView is HoneycombImageView {
                (honeycombView as! HoneycombImageView).animate(duration: duration, delay:delay)
            }
        }
    }
}

public class HoneycombImageView: UIImageView {
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.darkGrayColor()
        setupHexagonView()
    }
    
    // MARK: - setup layout
    public func setupHexagonView(){
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = bounds
        
        let width:CGFloat = frame.size.width
        let height:CGFloat = frame.size.height
        
        UIGraphicsBeginImageContext(frame.size)
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(width/2, 0))
        path.addLineToPoint(CGPointMake(width, height / 4))
        path.addLineToPoint(CGPointMake(width, height * 3 / 4))
        path.addLineToPoint(CGPointMake(width / 2, height))
        path.addLineToPoint(CGPointMake(0, height * 3 / 4))
        path.addLineToPoint(CGPointMake(0, height / 4))
        path.closePath()
        path.fill()
        maskLayer.path = path.CGPath
        UIGraphicsEndImageContext()
        layer.mask = maskLayer
    }
    
    
    // MARK:- animate
    public func animate(animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0)
    }
    
    public func animate(#duration: Double, animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0, delay:2.0)
    }
    
    public func animate(#duration: Double, delay: Double, animateType: HoneycombAnimateType = .FadeIn){
        switch animateType{
        case .FadeIn :
            alpha = 0.0
            let delay = (Double(rand() % 100) / 100.0) + delay
            UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alpha = 1.0
                }, completion: { animateFinish in
            })
        }
    }
}