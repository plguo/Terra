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

struct LabelInfo: Comparable {
    let name: String
    let score: Double
}

func <(lhs: LabelInfo, rhs: LabelInfo) -> Bool {
    return lhs.score < rhs.score || (lhs.score == rhs.score && lhs.score < rhs.score)
}

func ==(lhs: LabelInfo, rhs: LabelInfo) -> Bool {
    return (lhs.score == rhs.score && lhs.score == rhs.score)
}

protocol ImageUploaderDelegate {
    func identifiedLables(_ lables: [LabelInfo])
}

class ImageUploader{
    
    let storage : FIRStorage
    let storageRef : FIRStorageReference
    var dateFormatter = DateFormatter()
    var delegate : ImageUploaderDelegate?
    
    init(){
        storage = FIRStorage.storage(url: "gs://terra-47def.appspot.com/")
        storageRef = storage.reference()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }
    
    func constructRequest(url: String, feature: String) -> NSDictionary {
        let imageParams = ["source" : ["imageUri" : url]]
        let featureParams = [["type" : feature],]
        return ["image" : imageParams, "features" : featureParams]
    }
    
    func uploadImage(_ image: UIImage){
        let imageFilename = "scans/" + dateFormatter.string(from:Date()) + ".jpeg"
        let _ = "gs://terra-47def.appspot.com/" + imageFilename
        let imageRef = storageRef.child(imageFilename)
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else{
            return
        }
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.put(imageData, metadata: metadata){ [weak self] (data, error) in
            if error == nil {
                self?.getImageObject(data!.downloadURL()!.absoluteString)
            } else {
                print("ImageUploader: \(error)")
            }
        }
    }
    
    func getImageObject(_ imageurl: String){
        let requests = [constructRequest(url: imageurl, feature: "LOGO_DETECTION"),
                        constructRequest(url: imageurl, feature: "LABEL_DETECTION")]
        let parameters = ["requests": requests]
        
        Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=\(APIKEY)",
            method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [weak self] response in
                if let result = response.result.value as? NSDictionary {
                    if let responses = result["responses"] as? [NSDictionary] {
                        self?.handleResponses(responses)
                    }
                } else {
                    print("ImageUploader: \(response.error!)")
                }
        }
    }
    
    func handleResponses(_ responses: [NSDictionary]) {
        var tags = [LabelInfo]()
        for res in responses {
            if let labels = res.object(forKey: "labelAnnotations") as? [NSDictionary] {
                tags.append(contentsOf: self.handleLabels(labels))
            } else if let logos = res.object(forKey: "logoAnnotations") as? [NSDictionary] {
                tags.append(contentsOf: self.handleLabels(logos))
            }
        }
        
        tags.sort()
        tags.reverse()
        DispatchQueue.main.async {
            self.delegate?.identifiedLables(tags)
        }
    }
    
    func handleLabels(_ labels: [NSDictionary]) -> [LabelInfo] {
        var tags = [LabelInfo]()
        for label in labels {
            let score = (label["score"] as? NSNumber)?.doubleValue ?? 0.0
            let labelInfo = LabelInfo(name: (label["description"] as! String), score: score)
            tags.append(labelInfo)
        }
        return tags
    }
}
        
