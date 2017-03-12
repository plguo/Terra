//
//  QRViewController.swift
//  Terra
//
//  Created by Terra Team on 2017-03-11.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ImageUploaderDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var cameraView:UIView?
    
    var messageLabel: UILabel!
    var blurView: UIView!
    
    let stillImageOutput = AVCaptureStillImageOutput()
    var uploader : ImageUploader?
    
    var binType : String?
    
    let wiki = TerraWiki()
    let binWiki = ClassifyWaste()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captureButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        startCameraSession()
        addQrCodeFrameView()
        
        blurView = UIView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        blurView.layer.cornerRadius = 10.0
        
        messageLabel = UILabel()
        messageLabel.text = "Hello"
        messageLabel.font = UIFont.systemFont(ofSize: 20)
        messageLabel.textColor = UIColor.black
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.addSubview(messageLabel!)
        
        let labelVerticalConstraint = NSLayoutConstraint(item: messageLabel!, attribute: .centerX, relatedBy: .equal, toItem: blurView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let labelHorizontalConstraint = NSLayoutConstraint(item: messageLabel!, attribute: .centerY, relatedBy: .equal, toItem: blurView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        blurView.addConstraint(labelVerticalConstraint)
        blurView.addConstraint(labelHorizontalConstraint)
        
        view.addSubview(blurView)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[blur(==50)]", options: [], metrics: nil, views: ["blur" : blurView])
        let horizontalContraint = NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: messageLabel, attribute: .width, multiplier: 1.0, constant: 30.0)
        let centerConstraint = NSLayoutConstraint(item: blurView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        view.addConstraints(verticalConstraints)
        view.addConstraint(horizontalContraint)
        view.addConstraint(centerConstraint)
        
        uploader = ImageUploader()
        uploader!.delegate = self
        
        blurView.isHidden = true
        activityIndicator.isHidden = true
        
        wiki.fetchIndex()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func startCameraSession(){
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(self.stillImageOutput) {
                captureSession!.addOutput(self.stillImageOutput)
            }
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            let screenSize = UIScreen.main.bounds.size
            
            cameraView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            videoPreviewLayer?.frame = cameraView!.layer.bounds
            cameraView!.layer.addSublayer(videoPreviewLayer!)
            
            view.addSubview(cameraView!)
            view.sendSubview(toBack: cameraView!)
            
            // Start video capture.
            captureSession?.startRunning()
        }
        catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func addQrCodeFrameView(){
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel!.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel!.text = metadataObj.stringValue
            }
        }
    }
    
    @IBAction func classifyGarbage(_ sender: UIButton) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden  = false
        captureButton.isHidden = true
        blurView!.isHidden = true
        
        self.binType = nil
        
        stillImageOutput.captureStillImageAsynchronously(from: stillImageOutput.connection(withMediaType: AVMediaTypeVideo), completionHandler: {[weak self] (imageDataSampleBuffer, error) -> Void in
            if (imageDataSampleBuffer != nil && error == nil) {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!) as NSData
                if let image: UIImage = UIImage(data: imageData as Data){
                    self?.uploader?.uploadImage(image)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segue-to-map") {
            let controller = segue.destination as! MapViewController
            let bType = self.binType ?? "garbage"
            controller.targetType = bType
            controller.title = bType.capitalized
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    func identifiedLables(_ lables: [LabelInfo]) {
        if (lables.count > 0) {
            let firstLabel = lables.first!.name
            wiki.fetchProduct(lables) { [weak self] (labelName, category) in
                let productName = labelName ?? firstLabel
                self?.identifyBin(category, "waterloo", productName)
            }
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden  = true
            captureButton.isHidden = false
        }
        
    }
    
    func identifyBin(_ material: String,_ region: String, _ productName: String){
        binWiki.fetchBinType(material, region: region) { [weak self] (binType0) in
            
            let binType = binType0 == "undefined" ? "garbage" : binType0
            self?.messageLabel.text = "\(productName) / \(binType)"
            
            self?.binType = binType
            
            self?.blurView.isHidden = false
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden  = true
            self?.captureButton.isHidden = false
        }
    }
    
    @IBAction func unwindToCamera(unwindSegue: UIStoryboardSegue) {
        // Some code
    }
}

