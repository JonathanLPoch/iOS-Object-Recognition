//
//  ViewController.swift
//  iOS Object Recognition
//
//  Created by Jonathan Poch on 7/19/17.
//  Copyright © 2017 Jonathan Poch. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class ImageViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
  
  // MARK: - Properties
  
  var session : AVCaptureSession!
  var device : AVCaptureDevice!
  var output : AVCaptureVideoDataOutput!
  var taken = false
  
  // MARK: - UI Elements
  
  lazy var imageView: UIImageView = {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,
                      height: UIScreen.main.bounds.size.height-100)
    let imageView = UIImageView(frame: rect)
    imageView.backgroundColor = UIColor.red
    return imageView
  }()
  
  lazy var button: UIButton = {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-60, height: 60)
    let button = UIButton(frame: rect)
    button.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
    button.backgroundColor = UIColor.blue
    button.setTitle("Take Picture", for: .normal)
    button.layer.cornerRadius = 10.0
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    view.backgroundColor = UIColor.white
    
    view.addSubview(imageView)
    view.addSubview(button)
    
    if initCamera() {
      session.startRunning()
    }
  }
  
  override func viewDidLayoutSubviews() {
    imageView.snp.remakeConstraints{ (make) -> Void in
      make.top.equalTo(view.snp.top)
      make.centerX.equalTo(view.snp.centerX)
      make.width.equalTo(UIScreen.main.bounds.size.width)
      make.height.equalTo(UIScreen.main.bounds.size.height-100)
    }
    button.snp.remakeConstraints{ (make) -> Void in
      make.bottom.equalTo(view.snp.bottom).offset(-20)
      make.centerX.equalTo(view.snp.centerX)
      make.width.equalTo(UIScreen.main.bounds.size.width-60)
      make.height.equalTo(60)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Selector functions
  
  func takePicture(sender: UIButton) {
    print("Hi: \(taken)")
    if !self.taken {
      self.taken = true
      self.imageView.image = OpenCVWrapper.convert(self.imageView.image)
    }
  }
  
  // MARK: - Helper functions
  
  func initCamera() -> Bool {
    session = AVCaptureSession()
    session.sessionPreset = AVCaptureSessionPresetMedium
    
    let devices = AVCaptureDevice.devices()
    
    for d in devices! {
      if((d as AnyObject).position == AVCaptureDevicePosition.back){
        device = d as! AVCaptureDevice
      }
    }
    if device == nil {
      return false
    }
    
    do {
      let myInput: AVCaptureDeviceInput?
      try myInput = AVCaptureDeviceInput(device: device)
      
      if session.canAddInput(myInput) {
        session.addInput(myInput)
      } else {
        return false
      }
      
      output = AVCaptureVideoDataOutput()
      output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA) ]
      
      try device.lockForConfiguration()
      device.activeVideoMinFrameDuration = CMTimeMake(1, 15)
      device.unlockForConfiguration()
      
      let queue: DispatchQueue = DispatchQueue(label: "myqueue", attributes: [])
      output.setSampleBufferDelegate(self, queue: queue)
      
      output.alwaysDiscardsLateVideoFrames = true
    } catch let error as NSError {
      print(error)
      return false
    }
    
    if session.canAddOutput(output) {
      session.addOutput(output)
    } else {
      return false
    }
    
    for connection in output.connections {
      if let conn = connection as? AVCaptureConnection {
        if conn.isVideoOrientationSupported {
          conn.videoOrientation = AVCaptureVideoOrientation.portrait
        }
      }
    }
    return true
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                     from connection: AVCaptureConnection!) {
    DispatchQueue.main.async(execute: {
      let image: UIImage = CameraUtil.imageFromSampleBuffer(buffer: sampleBuffer)
      self.imageView.image = image;
    })
  }

}

