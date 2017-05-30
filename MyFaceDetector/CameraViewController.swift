//
//  CameraViewController.swift
//  MyFaceDetector
//
//  Created by Pedro Velmovitsky on 29/05/17.
//  Copyright © 2017 velmovitsky. All rights reserved.
//


import UIKit
import AVFoundation


class CameraViewController: UIViewController {
    
    
    @IBOutlet weak var cameraViewUI: UIView!
    
    @IBAction func takePhoto(_ sender: Any) {
        
        takePicture()
    }
    // Facilitation between I/O from camera
    var session : AVCaptureSession?
    
    // Camera per se
    var camera: AVCaptureDevice?
    
    // Camera preview
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Output from camera
    var cameraCaptureOutput: AVCapturePhotoOutput?
    
    
    func getFrontCamera() -> AVCaptureDevice?{
        let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        
        for device in videoDevices!{
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.front {
                return device
            }
        }
        return nil
    }
    
    func getBackCamera() -> AVCaptureDevice{
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        initializeCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        //        print("View size = ", cameraViewUI.frame.size)
        //        print("Self View Frame Size = ", view.frame.size)
        
        
    }
    
    func displayCapturedPhoto(capturePhoto: UIImage) {
        
        let imagePreviewViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewController") as! ImagePreviewController
        imagePreviewViewController.capturedImage = capturePhoto
        print (">>>>>> Captured foto: ", capturePhoto)
        present(imagePreviewViewController, animated: true, completion: nil)
    }
    
    func initializeCaptureSession() {
        
        // Configure Session
        
        if (session == nil) {
            
            session = AVCaptureSession()
            session?.sessionPreset = AVCaptureSessionPresetPhoto
        }
        
        
        var error: NSError?
        var cameraCaptureInput: AVCaptureDeviceInput!
        
        camera = getFrontCamera()
        
        do {
            cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            
        } catch let error1 as NSError {
            error = error1
            cameraCaptureInput = nil
            print(error!.localizedDescription)
            
        }
        
        for i : AVCaptureDeviceInput in (self.session?.inputs as! [AVCaptureDeviceInput]){
            self.session?.removeInput(i)
        }
        
        
        if error == nil && session!.canAddInput(cameraCaptureInput) {
            
            session?.addInput(cameraCaptureInput)
            
            
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            if session!.canAddOutput(cameraCaptureOutput) {
                session?.addOutput(cameraCaptureOutput)
                
                cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                cameraPreviewLayer?.frame.size.height = view.frame.size.height
                cameraPreviewLayer?.frame.size.width = view.frame.size.width
                
                
                //cameraPreviewLayer?.frame = cameraViewUI.bounds
                //                print("View size = ", cameraViewUI.frame.size)
                //                print("Camera Preview Layer size = ", cameraPreviewLayer?.frame.size)
                //                print("Screen Size = ", view.frame.size)
                
                cameraPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                
                cameraViewUI.layer.insertSublayer(cameraPreviewLayer!, at: 0)
                
                session?.startRunning()
            }
            
        }
        
        
    }
    
    func takePicture() {
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    // previewPhoto: photo with lower res
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let unrwappedError = error {
            
            print(unrwappedError.localizedDescription)
            
        } else {
            
            let sampleBuffer = photoSampleBuffer
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer!, previewPhotoSampleBuffer: nil)
            
            let dataProvider = CGDataProvider(data: dataImage! as CFData)
            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: CGColorRenderingIntent.defaultIntent)
            
            print (">>>>>>> DATA IMAGE: ", dataImage ?? print ("erro"))
            
            // if let finalImage = UIImage(data: dataImage) {
            let finalImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
            
            displayCapturedPhoto(capturePhoto: finalImage)
            //characterLayer.opacity = 1
            //session?.stopRunning()
            
            //detect(image: finalImage)
            
            // print (">>> vou chamar google vision api")
            // CHAMA GOOGLE VISION API - Base64 encode the image and create the request
            /*
             let faceDetection = FaceDetection()
             print ("instantiated face detection class")
             let binaryImageData = faceDetection.base64EncodeImage(pedroImage!)
             print("created binary image data")
             let json = faceDetection.createRequest(with: binaryImageData)
             print ("face detection request", json)
             */
        }
        
    }
    
    
    
    func detect(image: UIImage) {
        //characterLayer.removeFromSuperlayer()
        
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let personciImage = CIImage(cgImage: image.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are \(face.bounds)")
            
            session?.stopRunning()
            /*
             
             var faceViewBounds = face.bounds
             
             let viewSize = self.view.bounds.size
             
             let imageSizeHeight = view.frame.size.height / 2.32
             let imageSizeWidth = view.frame.size.width / 1.28
             print("Camera Preview Layer Size", viewSize)
             let scale = min((viewSize.width) / ciImageSize.width, (viewSize.height) / ciImageSize.height)
             let offsetX = ((viewSize.width) - ciImageSize.width * scale) / 2
             let offsetY = ((viewSize.height) - ciImageSize.height * scale) / 2
             
             faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
             faceViewBounds.origin.x += offsetX
             faceViewBounds.origin.y += offsetY
             
             let faceBox = UIView(frame: faceViewBounds)
             faceBox.layer.borderWidth = 3
             faceBox.layer.borderColor = UIColor.red.cgColor
             faceBox.backgroundColor = UIColor.clear
             self.view.addSubview(faceBox)
             
             if face.hasSmile {
             print("face is smiling ");
             }
             
             if face.hasMouthPosition {
             print("Mouth bounds are \(face.mouthPosition)")
             }
             
             if face.hasLeftEyePosition {
             print("Left eye bounds are \(face.leftEyePosition)")
             }
             
             if face.hasRightEyePosition {
             print("Right eye bounds are \(face.rightEyePosition)")
             var rightEye = CALayer()
             var image: UIImage?
             var position = face.rightEyePosition.applying(CGAffineTransform(scaleX: scale, y: scale))
             position.x += offsetX
             position.y += offsetY
             
             for mask in (selectedCharacter?.masks)! {
             
             if (mask.name == "rightEye") {
             print("WTF")
             image = mask.element
             }
             
             }
             rightEye.contents = image?.cgImage
             rightEye.contentsGravity = kCAGravityCenter
             rightEye.position = face.rightEyePosition
             cameraPreviewLayer?.addSublayer(rightEye)
             //cameraPreviewLayer?.addSublayer(characterLayer)
             } */
        } else {
            print("No faces found")
            let alert = UIAlertController(title: "No Face!", message: "No face was detected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //session?.stopRunning()
    }
    
    
}


