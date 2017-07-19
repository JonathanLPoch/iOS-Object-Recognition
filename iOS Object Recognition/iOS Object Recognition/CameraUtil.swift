//
//  CameraUtil.swift
//  iOS Object Recognition
//
//  Created by Jonathan Poch on 7/19/17.
//  Copyright © 2017 Jonathan Poch. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraUtil {
  class func imageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage {
    let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(buffer)!
    
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
    let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
    let imageRect: CGRect = CGRectMake(0, 0, pixelBufferWidth, pixelBufferHeight)
    let ciContext = CIContext.init()
    let cgimage = ciContext.createCGImage(ciImage, from: imageRect )
    
    let image = UIImage(cgImage: cgimage!)
    return image
  }
  
  class func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
  }
}
