//
//  HoneycombView.swift
//  HoneycombView
//
//  Created bysuzuki_keishi on 7/1/15.
//  Copyright (c) 2015suzuki_keishi. All rights reserved.
//

import UIKit

public enum HoneycombAnimateType { case FadeIn }

// MARK: - HoneycombView
public class HoneycombView: UIView{
    
    public var animateType:HoneycombAnimateType = .FadeIn
    
    public var diameter:CGFloat = 100
    public var margin:CGFloat = 10
    public var honeycombBackgroundColor = UIColor.blackColor()
    public var shouldCacheImage = false
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    public func configrationForHoneycombView() {
        let structure = constructView()
        
        for point in structure {
            let honeycombImageView = initializeHoneyCombImageView(point)
            addSubview(honeycombImageView)
        }
    }
    
    public func configrationForHoneycombViewWithImages(images:[UIImage]){
        let structure = constructView()
        
        for (index, point)in enumerate(structure){
            let honeycombImageView = initializeHoneyCombImageView(point)
            
            // set image if images have
            if images.count > index {
                honeycombImageView.image = images[index]
            }
            addSubview(honeycombImageView)
        }
 
    }
    
    public func configrationForHoneycombViewWithURL(urls:[String], var placeholder:UIImage? = nil){
        let structure = constructView()
        let holder = placeholder != nil ? placeholder! : UIImage()
        
        for (index, point)in enumerate(structure){
            let honeycombImageView = initializeHoneyCombImageView(point)
            
            if urls.count > index {
                honeycombImageView.imageFromURL(urls[index], placeholder: holder, shouldCacheImage: shouldCacheImage)
            }
            addSubview(honeycombImageView)
        }
    }
    
    private func initializeHoneyCombImageView(point:CGPoint) -> HoneycombImageView{
        let honeycombImageView = HoneycombImageView(frame: CGRectMake(0, 0, diameter, diameter))
        honeycombImageView.center = point
        honeycombImageView.backgroundColor = honeycombBackgroundColor
        return honeycombImageView
    }
    
    private func constructView() -> [CGPoint]{
        var structure = [CGPoint]()
        
        // initialize
        let side = (buttom: 0, left: 1, upper: 2, right: 3)
        let centerPoint = CGPointMake(frame.size.width/2, frame.size.height/2)
        let radius =  (diameter + margin) / 2.0
        let interval = CGSizeMake(radius * 2.0, radius * 2.0 - (diameter/4))
        let layerCount = Int(ceil(frame.height/max(interval.width, interval.height)))
        
        // configure view point
        for layerId in 0..<layerCount{
            // if layer is first of point
            if layerId == 0{
                structure.append(centerPoint)
                continue
            }
            
            let countInSide = layerId * 2
            for sideId in 0..<4 {
                var (dx:Int, dy:Int) = (0, 0)
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
                (honeycombView as! HoneycombImageView).animate(duration: duration, animateType:animateType)
            }
        }
    }
}

// MARK: - HoneycombImageView
public class HoneycombImageView: UIImageView {
    
    var color: UIColor =  UIColor.orangeColor(){
        didSet {
            backgroundColor = color
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHexagonView()
    }
    
    public func setupHexagonView(){
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = bounds
        
        let width:CGFloat = frame.size.width
        let height:CGFloat = frame.size.height
        
        // set hexagon using bezierpath
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
    
    
    // animate
    public func animate(animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0)
    }
    
    public func animate(#duration: Double, animateType: HoneycombAnimateType = .FadeIn){
        let delay = (Double(rand() % 100) / 100.0)
        
        switch animateType{
        case .FadeIn :
            alpha = 0.0
            UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alpha = 1.0
                }, completion: { animateFinish in
            })
       }
    }
}

// MARK: - extension UIImageView
public extension UIImageView {
    func imageFromURL(url: String, placeholder: UIImage, shouldCacheImage:Bool = true, fadeIn: Bool = true) {
        self.image = UIImage.imageFromURL(url, placeholder: placeholder, shouldCacheImage: true) {
            (image: UIImage?) in
            if image == nil {
                return
            }
            if fadeIn {
                self.alpha = 0.0
                let duration = 1.0
                let delay = (Double(rand() % 100) / 100.0)
                UIView.animateWithDuration(duration, delay: delay, options: nil, animations: {
                    self.alpha = 1.0
                    }, completion: { animateFinish in
                })
            }
            self.image = image
        }
    }
}

// MARK: - extension UIImage
public extension UIImage {
    
    private class func sharedHoneycombCache() -> NSCache! {
        struct StaticSharedHoneycombCache {
            static var sharedCache: NSCache? = nil
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&StaticSharedHoneycombCache.onceToken) {
            StaticSharedHoneycombCache.sharedCache = NSCache()
        }
        return StaticSharedHoneycombCache.sharedCache!
    }
    
    class func imageFromURL(url: String, placeholder: UIImage, shouldCacheImage: Bool = true, closure: (image: UIImage?) -> ()) -> UIImage? {
        // From Cache
        if shouldCacheImage {
            if UIImage.sharedHoneycombCache().objectForKey(url) != nil {
                closure(image: UIImage.sharedHoneycombCache().objectForKey(url) as? UIImage)
                return UIImage.sharedHoneycombCache().objectForKey(url) as! UIImage!
            }
        }
        // Fetch Image
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        if let nsURL = NSURL(string: url) {
            session.dataTaskWithURL(nsURL, completionHandler: {
                (response: NSData!, data: NSURLResponse!, error: NSError!) in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        closure(image: placeholder)
                    }
                }
                if let image = UIImage(data: response) {
                    if shouldCacheImage {
                        UIImage.sharedHoneycombCache().setObject(image, forKey: url)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        closure(image: image)
                    }
                }
                session.finishTasksAndInvalidate()
            }).resume()
        }
        return placeholder
    }
}