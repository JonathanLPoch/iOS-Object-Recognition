//
//  OpenCVWrapper.m
//  iOS Object Recognition
//
//  Created by Jonathan Poch on 7/19/17.
//  Copyright © 2017 Jonathan Poch. All rights reserved.
//

#import "OpenCVWrapper.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "iOS Object Recognition-Bridging-Header.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper

+(UIImage *)ConvertImage:(UIImage *)image {
  cv::Mat mat;
  UIImageToMat(image, mat);
  
  cv::Mat gray;
  cv::cvtColor(mat, gray, CV_RGB2GRAY);
  
  cv::Mat bin;
  cv::threshold(gray, bin, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
  
  UIImage *binImg = MatToUIImage(bin);
  return binImg;
}

@end
