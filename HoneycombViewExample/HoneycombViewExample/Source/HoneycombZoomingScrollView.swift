//
//  HoneycombZoomingScrollView.swift
//  HoneycombViewExample
//
//  Created by suzuki_keihsi on 2015/10/01.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

public class HoneycombZoomingScrollView:UIScrollView, UIScrollViewDelegate, HoneycombDetectingViewDelegate, HoneycombDetectingImageViewDelegate{
    
    var photoBrowser:HoneycombPhotoBrowser!
    var photo:HoneycombPhoto!{
        didSet{
            photoImageView.image = nil
            displayImage()
        }
    }
    
    var tapView:HoneycombDetectingView!
    var photoImageView:HoneycombDetectingImageView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, browser: HoneycombPhotoBrowser) {
        self.init(frame: frame)
        photoBrowser = browser
        
        setup()
    }
    
    
    func setup() {
        // tap
        tapView = HoneycombDetectingView(frame: bounds)
        tapView.delegate = self
        tapView.backgroundColor = UIColor.clearColor()
        tapView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(tapView)
        
        // image
        photoImageView = HoneycombDetectingImageView(frame: frame)
        photoImageView.delegate = self
        photoImageView.backgroundColor = UIColor.clearColor()
        addSubview(photoImageView)
        
        // self
        backgroundColor = UIColor.clearColor()
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    }
    
    // MARK: - override
    public override func layoutSubviews() {
        
        tapView.frame = bounds
        
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !CGRectEqualToRect(photoImageView.frame, frameToCenter){
            photoImageView.frame = frameToCenter
        }
    }
    
    public func setMaxMinZoomScalesForCurrentBounds(){
        
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        if photoImageView == nil {
            return
        }
        
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let maxScale:CGFloat = 4.0
        let minScale:CGFloat = min(xScale, yScale)
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        zoomScale = minScale
        
        photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height)
        setNeedsLayout()
    }
    
    public func prepareForReuse(){
        photo = nil
    }
    
    // MARK: - image
    public func displayImage(){
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSizeZero
        
        if photo != nil {
            
            let image = photoBrowser.imageForPhoto(photo)
            
            photoImageView.image = image

            var photoImageViewFrame = CGRectZero
            photoImageViewFrame.origin = CGPointZero
            photoImageViewFrame.size = image.size
            
            photoImageView.frame = CGRectMake(0, 0,
                min(photoImageViewFrame.size.width, photoImageViewFrame.size.height),
                min(photoImageViewFrame.size.width, photoImageViewFrame.size.height))
            
            contentSize = photoImageViewFrame.size
            
            setMaxMinZoomScalesForCurrentBounds()
        } else {
        }
        setNeedsLayout()
    }

    
    // MARK: - UIScrollViewDelegate
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
    }
   
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    // MARK: - HoneycombDetectingViewDelegate
    func handleSingleTap(view: UIView, touch: UITouch) {
    }
    
    func handleDoubleTap(view: UIView, touch: UITouch) {
    }
    
    // MARK: - Tap Detection
    
    
    
    
    
}