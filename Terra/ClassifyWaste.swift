//
//  ClassifyWaste.swift
//  Terra
//
//  Created by Silas Tsui on 2017-03-12.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import Foundation
import Alamofire

class ClassifyWaste {
    var index = [String:String]()
    
    func fetchIndex() {
        let indexUrl = "https://raw.githubusercontent.com/plguo/Terra-Recycle-Wiki/master/regions/index.md"
        Alamofire.request(indexUrl).responseString { [weak self] (response) in
            if (response.result.isSuccess) {
                let lines = (response.result.value! as NSString).components(separatedBy: "\n")
                
                var filename = "default.md"
                for line in lines {
                    if (line.hasPrefix("### ")) {
                        let filenameBegin = line.index(line.startIndex, offsetBy: 3)
                        filename = line.substring(from: filenameBegin)
                    } else if (line.hasPrefix("- ")) {
                        let productBegin = line.index(line.startIndex, offsetBy: 2)
                        let productName = line.substring(from: productBegin).lowercased()
                        
                        self?.index[productName] = filename
                    }
                }
                
                debugPrint(self!.index)
            } else {
                print("\(response.error)")
            }
        }
    }
    
    func fetchBinType(_ material: String, region region0: String, completion: @escaping (_ binType: String) -> Void) {
        
        
        let region = region0.lowercased()
        let regionUrl = "https://raw.githubusercontent.com/plguo/Terra-Recycle-Wiki/master/regions/" + region + ".md"
        Alamofire.request(regionUrl).responseString { (response) in
            if (response.result.isSuccess) {
                let lines = (response.result.value! as NSString).components(separatedBy: "\n")
                
                var binName = ""
                
                for line in lines {
                    if (line.hasPrefix("### ")) {
                        let binTypeBegin = line.index(line.startIndex, offsetBy: 4)
                        binName = line.substring(from: binTypeBegin).lowercased()
                    } else if (line.hasPrefix("- ")) {
                        let materialTypeBegin = line.index(line.startIndex, offsetBy: 2)
                        let materialType = line.substring(from: materialTypeBegin).lowercased()
                        if materialType == material{
                            completion(binName)
                            return
                        }
                    }
                }
            }
            
            completion("undefined")
        }
    }
}
