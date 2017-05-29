//
//  ImagePreviewController.swift
//  MyFaceDetector
//
//  Created by Pedro Velmovitsky on 29/05/17.
//  Copyright © 2017 velmovitsky. All rights reserved.
//

import Foundation
import UIKit

class ImagePreviewController : UIViewController {
    
    
    var capturedImage: UIImage?
    

    
    @IBOutlet weak var capturedImageView: UIImageView!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturedImageView.image = capturedImage
        print("View Size", self.view.frame.size)
        print("Image View Size", self.capturedImageView.frame.size)
        print("Image Size", self.capturedImageView.image?.size)
        
        detect()
        
        
    }
    func scaleImage(before: CGSize, after: CGSize) -> CGFloat {
        
        let height = after.height/before.height
        let width = after.width/before.width
        
        return width < height ? width : height
    }
    
    
    func detect() {
        
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        

        
        
        let personciImage = CIImage(cgImage: capturedImageView.image!.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
       let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are \(face.bounds)")
            
            let scale = scaleImage(before: (self.capturedImageView.image?.size)!, after: self.view.frame.size)
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
                
                mouthPosition.y = ((self.capturedImageView.image?.size.height)! - mouthPosition.y) * scale + (image?.size.height)! / 2
                
                
                mouth.position = mouthPosition
                capturedImageView.layer.addSublayer(mouth)
                print("mouthPosition: ", mouthPosition)
                

                
            }
            /*
             if face.hasLeftEyePosition {
             print("Left eye bounds are \(face.leftEyePosition)")
             let leftEye = CALayer()
             var image: UIImage?
             for mask in (selectedCharacter?.masks)! {
             
             if (mask.name == "leftEye") {
             print("Left Eye mask found")
             image = mask.element
             }
             }
             
             leftEye.contents = image?.cgImage
             leftEye.contentsGravity = kCAGravityCenter
             print("Left Eye height", image?.size.height)
             var leftEyePosition = face.leftEyePosition
             leftEyePosition.x = leftEyePosition.x * scale
             
             leftEyePosition.y = ((self.capturedImageView.image?.size.height)! - leftEyePosition.y) * scale + (image?.size.height)!
             
             capturedImageView.layer.addSublayer(leftEye)
             print("leftEyePosition: ", leftEyePosition)
             }
             
             if face.hasRightEyePosition {
             print("Right eye bounds are \(face.rightEyePosition)")
             let rightEye = CALayer()
             var image: UIImage?
             for mask in (selectedCharacter?.masks)! {
             
             if (mask.name == "rightEye") {
             print("Mouth mask found")
             image = mask.element
             }
             }
             
             rightEye.contents = image?.cgImage
             rightEye.contentsGravity = kCAGravityCenter
             print("Right Eye height", image?.size.height)
             var rightEyePosition = face.rightEyePosition
             rightEyePosition.x = rightEyePosition.x * scale
             //rightEyePosition.y = rightEyePosition.y * scale
             
             rightEyePosition.y = ((self.capturedImageView.image?.size.height)! - rightEyePosition.y) * scale + (image?.size.height)!
             
             capturedImageView.layer.addSublayer(rightEye)
             print("rightEyePosition: ", rightEyePosition)
             
             }
             */
        } else {
            print("No faces found")
        }
    }
}



