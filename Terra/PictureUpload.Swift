//
//  PictureUpload.Swift
//  
//
//  Created by Silas Tsui on 2017-03-11.
//
//

import Foundation

import UIKit
import Photos
import Alamofire
import Firebase
import FirebaseAuth
import FirebaseStorage

class ImageUploader{
    
    let storage = FIRStorage.storage()
    let storageRef : FIRStorageReference
    var dateFormatter = DateFormatter()
    
    init(){
        storageRef = storage.reference()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
    }
    
    func uploadImage(_ image: UIImage){
        let imageFilename = dateFormatter.string(from:Date())
        let imageRef = storageRef.child(imageFilename)
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else{
            return
        }
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(imageData, metadata: metadata){(metadata, error) in
            if error == nil {
                let downloadURL = metadata!.downloadURL()
                self.getImageObject(downloadURL!)
            } else {
                print("\(error)")
            }
        }
    }
    
    func getImageObject(_ imageurl: URL){
        let imageParams = ["source" : ["gcsImageUri" : imageurl]]
        let featureParams = [["type" : "LOGO_DETECTION"],]
        let parameters = ["requests": [["images" : imageParams, "features" : featureParams],]]
        
        Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(APIKEY)",
            method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{response in
                if let result = response.result.value as? NSDictionary{
                    let imageResult = result["response"]
                print(imageResult!)
                }
        }
    }
    
    
}
        
