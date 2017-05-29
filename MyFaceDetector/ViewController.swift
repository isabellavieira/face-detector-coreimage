//
//  ViewController.swift
//  MyFaceDetector
//
//  Created by Pedro Velmovitsky on 28/05/17.
//  Copyright © 2017 velmovitsky. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.image = UIImage(named: "image1")
        print("View Size", self.view.frame.size)
        print("Image View Size", self.imageView.frame.size)
        print("Image Size", self.imageView.image?.size)
        
        detect()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func detect() {
        
        let personciImage = CIImage(cgImage: imageView.image!.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)

        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are \(face.bounds)")
            
            
            //var faceViewBounds = face.bounds
            //let viewSize = imageView.bounds.size
            
            let scale = scaleImage(before: (self.imageView.image?.size)!, after: self.view.frame.size)
            print("Scale = ", scale)
 
            if face.hasSmile {
                print("face is smiling ");
            }
            
            if face.hasMouthPosition {
                print("Mouth bounds are \(face.mouthPosition)")
                let mouth = CALayer()
                let image = UIImage(named: "happyMouthNose")
                mouth.contents = image?.cgImage
                mouth.contentsGravity = kCAGravityCenter
                print("Mouth height", image?.size.height)
                
                var mouthPosition = face.mouthPosition
                mouthPosition.x = mouthPosition.x * scale
                
                mouthPosition.y = ((self.imageView.image?.size.height)! - mouthPosition.y) * scale + (image?.size.height)! / 2
                
                
                mouth.position = mouthPosition
                imageView.layer.addSublayer(mouth)
                print("mouthPosition: ", mouthPosition)

            }
            
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
                let leftEye = CALayer()
                let image = UIImage(named: "leftEye")
                leftEye.contents = image?.cgImage
                leftEye.contentsGravity = kCAGravityCenter
                print("Left Eye height", image?.size.height)
                
                var leftEyePosition = face.leftEyePosition
                leftEyePosition.x = leftEyePosition.x * scale
                
                leftEyePosition.y = ((self.imageView.image?.size.height)! - leftEyePosition.y) * scale + (image?.size.height)!
                
                
                leftEye.position = leftEyePosition
                imageView.layer.addSublayer(leftEye)
                print("leftEyePosition: ", leftEyePosition)
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
                let rightEye = CALayer()
                let image = UIImage(named: "rightEye")
                rightEye.contents = image?.cgImage
                rightEye.contentsGravity = kCAGravityCenter
                print("Right Eye height", image?.size.height)
                
                var rightEyePosition = face.rightEyePosition
                rightEyePosition.x = rightEyePosition.x * scale
                //rightEyePosition.y = rightEyePosition.y * scale
                    
               rightEyePosition.y = ((self.imageView.image?.size.height)! - rightEyePosition.y) * scale + (image?.size.height)!
                    

                rightEye.position = rightEyePosition
                imageView.layer.addSublayer(rightEye)
                print("rightEyePosition: ", rightEyePosition)
             
                }
            } else {
                print("No faces found")
            }
        }
    
    
    func scaleImage(before: CGSize, after: CGSize) -> CGFloat {
        
        let height = after.height/before.height
        let width = after.width/before.width
        
        return width < height ? width : height
        
    }


}

