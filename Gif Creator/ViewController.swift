//
//  ViewController.swift
//  Gif Creator
//
//  Created by Case Wright on 4/23/15.
//  Copyright (c) 2015 Case Wright. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import ImageIO

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePickerController = UIImagePickerController()
    var frameCount = 0;
    var videoLength:Float = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = true;
        imagePickerController.mediaTypes = [kUTTypeMovie]
        //self.navigationController?.navigationBar.barTintColor = UIColorFromRGB("66CC66")
        //self.navigationController?.navigationBar.titleTextAttributes = [UITextAttributeTextColor: UIColor.orangeColor()]
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseVideoBtnPressed(sender: UIButton) {
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
            
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        
        let video = info.objectForKey(UIImagePickerControllerMediaURL) as NSURL
        
        
        
        frameCount = countVideoFrames(video)
        
        performSegueWithIdentifier("properties", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "properties")
        {
            let vc:PropertiesViewController = segue.destinationViewController as PropertiesViewController
            
            //vc.gifImages = images;
            vc.videoLength = videoLength;
        }
    }
    
    func countVideoFrames(videoUrl:NSURL) -> Int {
        var asset = AVURLAsset(URL: videoUrl, options: nil)
        videoLength = Float(CMTimeGetSeconds(CMTime(value: asset.duration.value, timescale: asset.duration.timescale, flags: asset.duration.flags, epoch: asset.duration.epoch)))
        //videoLength = Int((asset.duration.timescale as Int32 / asset.duration.value as Int32) as Int32)
        var reader = AVAssetReader(asset: asset, error: nil)
        var videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        //var videoSetting = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        //var videoTrackOutput=AVAssetReaderTrackOutput(track:videoTrack as AVAssetTrack , outputSettings:)
        
        var readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_420YpCbCr8BiPlanarFullRange])
        
        reader.addOutput(readerOutput)
        reader.startReading()
        var nFrames = 0
        //var imgGenerator = AVAssetImageGenerator(asset: asset)
        println(NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String)
        
        while true {
            var sampleBuffer = readerOutput.copyNextSampleBuffer()
            if sampleBuffer == nil {
                println("nil")
                break;
            }
            let cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
            let ciImage = CIImage(CVPixelBuffer: cvImage)
            let context = CIContext(options: nil)
            let videoImage = context.createCGImage(ciImage, fromRect: CGRectMake(0, 0,
                CGFloat(CVPixelBufferGetWidth(sampleBuffer)),
                CGFloat(CVPixelBufferGetHeight(sampleBuffer))))
            let img = UIImage(CGImage: videoImage)
            /*
            let width = img?.size.width
            let height = img?.size.height
            let newWidth = width! / 2
            let newHeight = height! / 2
            
            let newSize = CGSizeMake(newWidth, newHeight);
            UIGraphicsBeginImageContext(newSize);
            img?.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))*/
            //let returnImg = UIGraphicsGetImageFromCurrentImageContext();
            //UIGraphicsEndImageContext()
            
            FileDelete.deleteSubDirectoryFromTemporaryDirectory("imgs")
            
            var imgData = UIImageJPEGRepresentation(img, 1.0);
            FileSave.saveDataToTemporaryDirectory(imgData, path: "\(nFrames).jpg", subdirectory: "imgs")
            nFrames++
        }
        UIGraphicsEndImageContext()
        
        return nFrames;
    }
}

