//
//  PropertiesViewController.swift
//  Gif Creator
//
//  Created by Case Wright on 4/23/15.
//  Copyright (c) 2015 Case Wright. All rights reserved.
//

import UIKit
import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import ImageIO

class PropertiesViewController: UIViewController {

    @IBOutlet weak var FPSTextField: UITextField!
    var gifImages:[String] = [];
    var videoLength:Float = 0;
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    let imgTempPath = (NSTemporaryDirectory() as String).stringByAppendingString("/imgs/")
    let fileManager = NSFileManager.defaultManager()
    var error : NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(imgTempPath)
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(imgTempPath)!
        
        while let element = enumerator.nextObject() as? String {
            gifImages.append((NSTemporaryDirectory() as String).stringByAppendingString("/imgs/\(element)"))
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func speedSliderValueChanged(sender: UISlider) {
        speedLabel.text = "\(sender.value)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func createGifBtnPressed(sender: AnyObject) {
        
        let delay:Double = (Double(videoLength) / Double(gifImages.count) * Double(speedSlider.value))
        println("delay: \(delay)")
        createGIF(/*with: gifImages, */loopCount: 0, frameDelay: delay) { (data, error) -> () in
            var library:ALAssetsLibrary = ALAssetsLibrary();
            library.writeImageDataToSavedPhotosAlbum(data, metadata: nil, completionBlock: { (assetURL, error) -> Void in
                
            })
        }
        
    }
    
    func createGIF(/*with images: [UIImage], */loopCount: Int = 0, frameDelay: Double, callback: (data: NSData?, error: NSError?) -> ()) {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory)?.URLByAppendingPathComponent("animated.gif")
        println(url)
        if let url = url {
            let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, UInt(gifImages.count), nil)
            CGImageDestinationSetProperties(destination, fileProperties)
            
            for i in 0..<gifImages.count {
                CGImageDestinationAddImage(destination, UIImage(contentsOfFile: gifImages[i])?.CGImage/*images[i].CGImage*/, frameProperties)
            }
            
            if CGImageDestinationFinalize(destination) {
                callback(data: NSData(contentsOfURL: url), error: nil)
            } else {
                callback(data: nil, error: NSError())
            }
        } else  {
            callback(data: nil, error: NSError())
        }
    }
}
