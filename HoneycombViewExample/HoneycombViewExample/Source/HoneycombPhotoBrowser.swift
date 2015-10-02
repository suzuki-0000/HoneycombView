//
//  HoneycombPhotoBrowser.swift
//  HoneycombViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

// MARK: - HoneycombPhotoBrowser
public class HoneycombPhotoBrowser: UIViewController, UIScrollViewDelegate{
    
    final let pageIndexTagOffset = 1000
    
    var pagingScrollView:UIScrollView!
    var panGesture:UIPanGestureRecognizer!
    var visiblePages:Set<HoneycombZoomingScrollView> = Set()
    var recycledPages:Set<HoneycombZoomingScrollView> = Set()
    var initialPageIndex:Int = 0
    var currentPageIndex:Int = 0
    var numberOfPhotos:Int{
        return photos.count
    }
    var photos:[HoneycombPhoto] = [HoneycombPhoto]()
    var senderViewForAnimation:UIView = UIView()
    var senderViewOriginalFrame:CGRect = CGRectZero
    var resizableImageView:UIImageView = UIImageView()
    
    var isDraggingPhoto:Bool = false
    var isViewActive:Bool = false
    var performingLayout:Bool = false
    
    var applicationWindow:UIWindow!
    
    var doneButton:UIButton!
    
    var firstX:CGFloat = 0.0
    var firstY:CGFloat = 0.0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        setup()
    }
    
    convenience init(photos:[HoneycombPhoto], animatedFromView:UIView) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.senderViewForAnimation = animatedFromView
    }
    
    func setup() {
        applicationWindow = (UIApplication.sharedApplication().delegate?.window)!
        
        modalPresentationStyle = UIModalPresentationStyle.Custom
        modalPresentationCapturesStatusBarAppearance = true
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleIDMPhotoLoadingDidEndNotification:", name: "loading_photo_did", object: nil)
        
    }
    
    public func handleIDMPhotoLoadingDidEndNotification(notification: NSNotification){
        let photo = notification.object as! HoneycombPhoto
        let page = pageDisplayingAtPhoto(photo)
        page.displayImage()
        loadAdjacentPhotosIfNecessary(photo)
    }
    // MARK: - override
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        view.clipsToBounds = true
        
        // setup paging
        let pagingScrollViewFrame = frameForPagingScrollView()
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.pagingEnabled = true
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = true
        pagingScrollView.showsVerticalScrollIndicator = true
        pagingScrollView.backgroundColor = UIColor.blackColor()
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        // transition
        performPresentAnimation()
        
        // close
        doneButton = UIButton(type: UIButtonType.Custom)
        doneButton.frame = CGRectMake(view.bounds.width - 75, 30, 55, 26)
        doneButton.alpha = 1.0
        doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.backgroundColor = UIColor.blackColor()
        doneButton.layer.cornerRadius = 3.0
        doneButton.layer.borderColor = UIColor.whiteColor().CGColor
        doneButton.layer.borderWidth = 1.0
        view.addSubview(doneButton)
        
        // gesture
        panGesture = UIPanGestureRecognizer(target: self, action: "panGestureRecognized:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        reloadData()
    }
    
    public override func viewWillLayoutSubviews() {
        performingLayout = true
        
        pagingScrollView.frame = frameForPagingScrollView()
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        
//        for page in visiblePages{
//            let index = page.tag
//            page.frame = frameForPageAtIndex(index)
//        }
//        
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        didStartViewingPageAtIndex(currentPageIndex)
        
        performingLayout = false
        
        super.viewWillLayoutSubviews()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        currentPageIndex = 0
        pagingScrollView = nil
        visiblePages = Set()
        recycledPages = Set()
    }
    
    public func reloadData(){
        performLayout()
        view.setNeedsLayout()
    }
    
    public func releaseAllUnderlyingPhotos(){
        photos = [HoneycombPhoto]()
    }
    
    public func performLayout(){
        performingLayout = true
        
        visiblePages.removeAll()
        recycledPages.removeAll()
        
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        
        tilePages()
        
        performingLayout = false
        
        view.addGestureRecognizer(panGesture)
        
    }
    
    public func loadAdjacentPhotosIfNecessary(photo: HoneycombPhoto){
        let page = pageDisplayingAtPhoto(photo)
        let pageIndex = page.tag - pageIndexTagOffset
        if currentPageIndex == pageIndex{
            if pageIndex > 0 {
            }
            if pageIndex < numberOfPhotos - 1 {
            }
            
        }
    }
    
    public func frameForPagingScrollView() -> CGRect{
        var frame = view.bounds
        frame.origin.x -= 10
        frame.size.width += (2 * 10)
        return frame
    }
    
    public func contentOffsetForPageAtIndex(index:Int) -> CGPoint{
        let pageWidth = pagingScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPointMake(newOffset, 0)
    }
    
    public func contentSizeForPagingScrollView() -> CGSize {
        let bounds = pagingScrollView.bounds
        return CGSizeMake(bounds.size.width * CGFloat(numberOfPhotos), bounds.size.height)
    }
    
    // MARK: - func
    public func didStartViewingPageAtIndex(index: Int){
        let currentPhoto = photoAtIndex(index)
        loadAdjacentPhotosIfNecessary(currentPhoto)
    }
    
    public func initializePageIndex(index: Int){
        var i = index
        if index >= numberOfPhotos {
            i = numberOfPhotos - 1
        }
        
        initialPageIndex = i
        currentPageIndex = i
        
        if isViewLoaded() {
            jumpToPageAtIndex(index)
            if isViewActive {
                tilePages()
            }
        }
    }
    
    public func jumpToPageAtIndex(index:Int){
        if index < numberOfPhotos {
            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.setContentOffset(CGPointMake(pageFrame.origin.x - 10, 0), animated: true)
        }
    }
    
    public func photoAtIndex(index: Int) -> HoneycombPhoto {
        return photos[index]
    }
    
    public func frameForPageAtIndex(index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
   
    public func imageForPhoto(photo:HoneycombPhoto) -> UIImage{
        return photo.underlyingImage
    }
    
    // MARK: - panGestureRecognized
    
    public func panGestureRecognized(sender:UIPanGestureRecognizer){
        
        let scrollView = pageDisplayedAtIndex(currentPageIndex)
        
        let viewHeight = scrollView.frame.size.height
        let viewHalfHeight = viewHeight/2
        
        var translatedPoint = sender.translationInView(self.view)
        
        // gesture began
        if sender.state == .Began {
            firstX = scrollView.center.x
            firstY = scrollView.center.y
            
            senderViewForAnimation.hidden = (currentPageIndex == initialPageIndex)
            
            isDraggingPhoto = true
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPointMake(firstX, firstY + translatedPoint.y)
        scrollView.center = translatedPoint
        debugPrint(translatedPoint)
        debugPrint(scrollView.center)
        
        //let newY = scrollView.center.y - viewHalfHeight
        //let newAlpha = 1 - fabs(newY) / viewHeight
        
        view.opaque = true
        
        // gesture end
        if sender.state == .Ended{
            if scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40 {
                if currentPageIndex == initialPageIndex {
                    performCloseAnimationWithScrollView(scrollView)
                    return
                }
                
                let finalX:CGFloat = firstX
                var finalY:CGFloat = 0.0
                let windowHeight = applicationWindow.frame.size.height
                
                if scrollView.center.y > viewHalfHeight+30 {
                    finalY = windowHeight * 2.0
                } else {
                    finalY = -(viewHalfHeight)
                }
                
                let animationDuration = 0.35
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                scrollView.center = CGPointMake(finalX, finalY)
                UIView.commitAnimations()
                
                senderViewForAnimation.hidden = false
                prepareForClosePhotoBrowser()
                dismissViewControllerAnimated(true, completion: {})
             } else {
            
                // Continue Showing View
                isDraggingPhoto = false
                setNeedsStatusBarAppearanceUpdate()
                
                let velocityY:CGFloat = 0.35 * sender.velocityInView(self.view).y
                let finalX:CGFloat = firstX
                let finalY:CGFloat = viewHalfHeight
                
                let animationDuration = Double(abs(velocityY) * 0.0002 + 0.2)
                
                debugPrint(velocityY)
                debugPrint(animationDuration)
                
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
                scrollView.center = CGPointMake(finalX, finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    
    // MARK: - perform
    public func performPresentAnimation(){
        view.alpha = 0.0
        pagingScrollView.alpha = 0.0
        
        let imageFromView = getImageFromView(senderViewForAnimation)
        
        senderViewOriginalFrame = (senderViewForAnimation.superview?.convertRect(senderViewForAnimation.frame, toView:nil))!
        
        let screenBound = UIScreen.mainScreen().bounds
        let screenWidth:CGFloat = screenBound.size.width
        let screenHeight:CGFloat = screenBound.size.height
        
        let fadeView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        fadeView.backgroundColor = UIColor.clearColor()
        applicationWindow.addSubview(fadeView)
        
        resizableImageView = UIImageView(image: imageFromView)
        resizableImageView.frame = senderViewOriginalFrame
        resizableImageView.clipsToBounds = true
        resizableImageView.contentMode = .ScaleAspectFill
        applicationWindow.addSubview(resizableImageView)
        
        senderViewForAnimation.hidden = true
        
        let scaleFactor = imageFromView.size.width / screenWidth
        let finalImageViewFrame = CGRectMake(0, (screenHeight/2) - ((imageFromView.size.height / scaleFactor)/2), screenWidth, imageFromView.size.height / scaleFactor)
        
        UIView.animateWithDuration(0.35,
            animations: { () -> Void in
                fadeView.backgroundColor = UIColor.blackColor()
                self.resizableImageView.layer.frame = finalImageViewFrame
            },
            completion: { (Bool) -> Void in
                self.view.alpha = 1.0
                self.pagingScrollView.alpha = 1.0
                self.resizableImageView.alpha = 0.0
                
                fadeView.removeFromSuperview()
        })
        
    }
    
    public func performCloseAnimationWithScrollView(scrollView:HoneycombZoomingScrollView) {
        
        let screenBound = UIScreen.mainScreen().bounds
        let screenWidth:CGFloat = screenBound.size.width
        let screenHeight:CGFloat = screenBound.size.height
        
        let fadeView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        fadeView.backgroundColor = UIColor.clearColor()
        fadeView.alpha = 1.0
        applicationWindow.addSubview(fadeView)
        
        resizableImageView.alpha = 1.0
        resizableImageView.clipsToBounds = true
        resizableImageView.contentMode = .ScaleAspectFill
        applicationWindow.addSubview(resizableImageView)
        
        view.hidden = true
        
        UIView.animateWithDuration(0.35,
            animations: { () -> Void in
                fadeView.alpha = 0.0
                self.view.alpha = 0.0
                self.resizableImageView.layer.frame = self.senderViewOriginalFrame
            },
            completion: { (Bool) -> Void in
                self.senderViewForAnimation.hidden = false
                
                fadeView.removeFromSuperview()
                self.resizableImageView.removeFromSuperview()
                self.prepareForClosePhotoBrowser()
                self.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
    public func prepareForClosePhotoBrowser(){
        applicationWindow.removeGestureRecognizer(panGesture)
        
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    public func getImageFromView(sender:UIView) -> UIImage{
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = sender.bounds
        
        let width:CGFloat = sender.frame.size.width
        let height:CGFloat = sender.frame.size.height
        
        // set hexagon using bezierpath
        UIGraphicsBeginImageContext(sender.frame.size)
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
        sender.layer.mask = maskLayer
        sender.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    //MARK - paging
    public func tilePages(){
        
        let visibleBounds = pagingScrollView.bounds
        
        var firstIndex = Int(floor((CGRectGetMinX(visibleBounds) + 10 * 2) / CGRectGetWidth(visibleBounds)))
        var lastIndex  = Int(floor((CGRectGetMaxX(visibleBounds) - 10 * 2 - 1) / CGRectGetWidth(visibleBounds)))
        if firstIndex < 0 {
            firstIndex = 0
        }
        if firstIndex > numberOfPhotos - 1 {
            firstIndex = numberOfPhotos - 1
        }
        if lastIndex < 0 {
            lastIndex = 0
        }
        if lastIndex > numberOfPhotos - 1 {
            lastIndex = numberOfPhotos - 1
        }
        
//        var pageIndex = 0
//        for page in visiblePages {
//            pageIndex = page.tag
//            if pageIndex < firstIndex || pageIndex > lastIndex {
//                recycledPages.insert(page)
//                page.removeFromSuperview()
//            }
//        }
//        
//        visiblePages = visiblePages.subtract(recycledPages)
//        while recycledPages.count > 2 {
//            recycledPages.removeFirst()
//        }
        
        // add missing
        for(var index = firstIndex; index <= lastIndex; index++){
            if !isDisplayingPageForIndex(index){
                
                let page = HoneycombZoomingScrollView(frame: view.frame, browser: self)
                page.frame = frameForPageAtIndex(index)
                page.tag = index + pageIndexTagOffset
                page.photo = photoAtIndex(index)
                
                visiblePages.insert(page)
                pagingScrollView.addSubview(page)
                
            }
        }
    }
    
    public func isDisplayingPageForIndex(index: Int) -> Bool{
        for page in visiblePages{
            if (page.tag - pageIndexTagOffset) == index {
                return true
            }
        }
        return false
    }
    
    public func pageDisplayedAtIndex(index: Int) -> HoneycombZoomingScrollView {
        var thePage:HoneycombZoomingScrollView = HoneycombZoomingScrollView()
        for page in visiblePages {
            if (page.tag - pageIndexTagOffset) == index {
               thePage = page
               break
            }
        }
        return thePage
    }
    
    public func pageDisplayingAtPhoto(photo: HoneycombPhoto) -> HoneycombZoomingScrollView {
        var thePage:HoneycombZoomingScrollView = HoneycombZoomingScrollView()
        for page in visiblePages {
            if page.photo == photo {
                thePage = page
                break
            }
        }
        return thePage
    }
    
    // MARK: - Button
    public func doneButtonPressed(sender:UIButton) {
        if currentPageIndex == initialPageIndex {
            let scrollView = pageDisplayedAtIndex(currentPageIndex)
            performCloseAnimationWithScrollView(scrollView)
        } else {
            senderViewForAnimation.hidden = false
            prepareForClosePhotoBrowser()
            dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    
    // MARK: -  UIScrollView Delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isViewActive {
            return
        }
        if performingLayout {
            return
        }
        
        tilePages()
        
        // Calculate current page
        let visibleBounds = pagingScrollView.bounds
        var index = Int(floor(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)))
        
        debugPrint(index)
        if index < 0 {
            index = 0
        }
        if index > numberOfPhotos - 1 {
            index = numberOfPhotos
        }
        let previousCurrentPage = currentPageIndex
        currentPageIndex = index
        if currentPageIndex != previousCurrentPage {
            didStartViewingPageAtIndex(currentPageIndex)
        }
    }
}