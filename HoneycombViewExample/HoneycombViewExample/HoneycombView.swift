//
//  HoneycombView.swift
//  HoneycombView
//
//  Created by suzuki_keishi on 7/1/15.
//  Copyright (c) 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

public enum HoneycombAnimateType { case FadeIn }

// MARK: - HoneycombView
public class HoneycombView: UIView{
    
    public var animateType:HoneycombAnimateType = .FadeIn
    
    public var diameter:CGFloat = 100
    public var margin:CGFloat = 10
    public var honeycombBackgroundColor = UIColor.blackColor()
    public var shouldCacheImage = false
    public var images = [IDMPhoto]()
    public var urls = [String]()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    public func configrationForHoneycombView() {
        let structure = constructView()
        
        for point in structure {
            addSubview(initializeHoneyCombChildView(point))
        }
    }
    
    public func configrationForHoneycombViewWithImages(images:[UIImage]){
        self.images = resizeImage(images)
        
        let structure = constructView()
        
        for (index, point)in structure.enumerate(){
            let v = initializeHoneyCombChildView(point)
            v.tag = index
            
            // set image if images have
            if self.images.count > index {
                v.setHoneycombImage(self.images[index])
            }
            addSubview(v)
        }
    }
    
    public func configrationForHoneycombViewWithURL(urls:[String], placeholder:UIImage? = nil){
        self.images = createImageFromUrl(urls)
        
        let structure = constructView()
        
        for (index, point)in structure.enumerate(){
            let v = initializeHoneyCombChildView(point)
            v.tag = index
            
            if urls.count > index {
                v.setHoneycombImageFromURL(urls[index])
            }
            addSubview(v)
        }
    }
    
    private func resizeImage(images:[UIImage]) -> [IDMPhoto]{
        var idmPhotos = [IDMPhoto]()
        
        for image in images {
            let imageView = UIImageView(image: image)
            // set hexagon using bezierpath
            let width:CGFloat = imageView.frame.size.width
            let height:CGFloat = imageView.frame.size.height
            
            UIGraphicsBeginImageContext(imageView.frame.size)
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(width/2, 0))
            path.addLineToPoint(CGPointMake(width, height / 4))
            path.addLineToPoint(CGPointMake(width, height * 3 / 4))
            path.addLineToPoint(CGPointMake(width / 2, height))
            path.addLineToPoint(CGPointMake(0, height * 3 / 4))
            path.addLineToPoint(CGPointMake(0, height / 4))
            path.closePath()
            path.fill()
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.CGPath
            imageView.layer.mask = maskLayer
            imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            idmPhotos.append(IDMPhoto(image: result))
        }
        return idmPhotos
    }
    
    private func createImageFromUrl(urls:[String]) -> [IDMPhoto]{
        var idmPhotos = [IDMPhoto]()
        
        for url in urls {
            idmPhotos.append(IDMPhoto(URL: NSURL(string: url)))
        }
        
        return idmPhotos
    }
    
    private func initializeHoneyCombChildView(point:CGPoint) -> HoneycombChildView{
        let v = HoneycombChildView(frame: CGRectMake(0, 0, diameter, diameter))
        v.center = point
        v.backgroundColor = honeycombBackgroundColor
        return v
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
                var direction = (x: 0, y:0)
                // point x, y from center point
                var point = (a:layerId, b:layerId)
                
                // set direction and point from center
                switch sideId {
                case side.buttom:
                    (direction.x, direction.y) = (-1, 0)
                    (point.a, point.b) = (layerId, layerId)
                case side.left:
                    (direction.x, direction.y) = (0, -1)
                    (point.a,   point.b) = (-layerId, layerId)
                case side.upper:
                    (direction.x, direction.y) = (1, 0)
                    (point.a, point.b) = (-layerId, -layerId)
                case side.right:
                    (direction.x, direction.y) = (0, 1)
                    (point.a, point.b) = (layerId, -layerId)
                default: break
                }
                
                // forward next point of side
                for indexInSide in 0..<countInSide {
                    let x = point.a + direction.x * indexInSide
                    let y = point.b + direction.y * indexInSide
                    
                    var actualPoint = (x:CGFloat(0.0), y:CGFloat(0.0))
                    // go forward a half when odd
                    if(y % 2 == 0) {
                        actualPoint.x = centerPoint.x + interval.width * CGFloat(x)
                    } else {
                        actualPoint.x = centerPoint.x + interval.width * (CGFloat(x) + 0.5)
                    }
                    actualPoint.y = centerPoint.y + interval.height * CGFloat(y)
                    
                    // finally add point.
                    structure.append(CGPointMake(actualPoint.x, actualPoint.y))
                }
            }
        }
        return structure
    }
    
    
    public func animate(){
        animate(2.0)
    }
    
    public func animate(duration: Double){
        animate(duration, delay:0.0)
    }
    
    public func animate(duration: Double, delay: Double){
        for honeycombView in subviews {
            if honeycombView is HoneycombChildView {
                (honeycombView as! HoneycombChildView).animate(duration: duration, animateType:animateType)
            }
        }
    }
}

// MARK: - HoneycombImageView
public class HoneycombChildView: UIButton{
    
    var honeycombImageView:HoneycombImageView!
    
    var color: UIColor =  UIColor.orangeColor(){
        didSet {
            backgroundColor = color
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHexagonView()
        addTarget(self, action: Selector("imageTapped:"), forControlEvents: .TouchUpInside)
        
        honeycombImageView = HoneycombImageView(frame: frame)
        addSubview(honeycombImageView)
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
    
    func imageTapped(sender: UIButton){
        animateTouched()
       
        if let sv = superview as? HoneycombView{
            let browser = IDMPhotoBrowser(photos: sv.images, animatedFromView: sender)
            browser!.leftArrowImage = UIImage(named: "IDMPhotoBrowser_arrowLeft")
            browser!.rightArrowImage = UIImage(named: "IDMPhotoBrowser_arrowRight")
            browser!.displayActionButton = true
            browser!.displayArrowButton = true
            browser!.displayCounterLabel = true
            browser!.usePopAnimation = true
            browser!.scaleImage = sender.currentImage
            browser!.setInitialPageIndex(UInt(sender.tag))
            
            if let vc = UIApplication.sharedApplication().keyWindow?.rootViewController{
                vc.presentViewController(browser, animated: true, completion: {})
            }
        }
    }
    
    func setHoneycombImage(image:IDMPhoto){
        honeycombImageView.image = image.underlyingImage()
    }
    
    func setHoneycombImageFromURL(url:String){
        honeycombImageView.imageFromURL(url, placeholder: UIImage())
    }
    
    // animate
    func animateTouched() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [0, -0.1, 0, 0.1, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.duration = CFTimeInterval(0.3)
        animation.additive = true
        animation.repeatCount = 1
        animation.beginTime = CACurrentMediaTime()
        layer.addAnimation(animation, forKey: "pop")
    }
    
    public func animate(animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0)
    }
    
    public func animate(duration duration: Double, animateType: HoneycombAnimateType = .FadeIn){
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

// MARK: - HoneycombImageView
public class HoneycombImageView: UIImageView {
    
    var color: UIColor =  UIColor.orangeColor(){
        didSet {
            backgroundColor = color
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
                UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: {
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
                (response: NSData?, data: NSURLResponse?, error: NSError?) in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        closure(image: placeholder)
                    }
                }
                if let res = response, let image = UIImage(data: res) {
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