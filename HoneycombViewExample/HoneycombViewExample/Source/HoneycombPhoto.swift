//
//  HoneycombPhoto.swift
//  HoneycombViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

// MARK: - HoneycombPhoto
public class HoneycombPhoto:NSObject {
    
    var underlyingImage:UIImage!
    
    var caption:String?
    var placeHolderImage:UIImage?
    var photoURL:String?
    
    override init() {
        super.init()
    }
    
    convenience init(image: UIImage){
        self.init()
        underlyingImage = image;
    }
    
    public func getUnderlyingImage() -> UIImage {
        return underlyingImage
    }
    
    public func unloadUnderlyingImage(){
        if underlyingImage != nil {
            underlyingImage = nil
        }
    }
    
    // MARK: - class func
    class func photoWithImage(image: UIImage) -> HoneycombPhoto {
        return HoneycombPhoto(image: image)
    }
    
}