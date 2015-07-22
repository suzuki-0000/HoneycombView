//
//  HoneycombImageView.swift
//  HoneycombView
//
//

import UIKit

enum HoneycombAnimateType { case FadeIn }

class HoneycombImageView: UIImageView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.darkGrayColor()
        setupHexagonView()
    }
    
    // MARK: - setup layout
    func setupHexagonView(){
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = bounds
       
        let width:CGFloat = frame.size.width
        let height:CGFloat = frame.size.height
        let hPadding:CGFloat = 0.0
        
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
    func animate(animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0)
    }
    
    func animate(#duration: Double, animateType: HoneycombAnimateType = .FadeIn){
        animate(duration:2.0, delay:2.0)
    }
    
    func animate(#duration: Double, delay: Double, animateType: HoneycombAnimateType = .FadeIn){
        switch animateType{
        case .FadeIn :
            alpha = 0.0
            let delay = Double(rand() % 100) / 100.0
            UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alpha = 1.0
            }, completion: { animateFinish in
            })
        }
    }
}