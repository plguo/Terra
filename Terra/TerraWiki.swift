//
//  TerraWiki.swift
//  Terra
//
//  Created by Edward Guo on 2017-03-12.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import Foundation
import Alamofire

class TerraWiki {
    var index = [String:String]()
    
    func fetchIndex() {
        let indexUrl = "https://raw.githubusercontent.com/plguo/Terra-Recycle-Wiki/master/products/index.md"
        Alamofire.request(indexUrl).responseString { [weak self] (response) in
            if (response.result.isSuccess) {
                let lines = (response.result.value! as NSString).components(separatedBy: "\n")
                
                var filename = "default.md"
                for line in lines {
                    if (line.hasPrefix("## ")) {
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
    
    func fetchProduct(_ labels: [LabelInfo], completion: @escaping (_ label: String?, _ category: String) -> Void) {
        guard labels.count > 0 else {
            completion(nil, "undefined")
            return
        }
        
        let originalName = labels.first!.name
        let name = originalName.lowercased()
        let remaining = Array(labels.dropFirst())
        
        guard let filename = index[name] else {
            self.fetchProduct(remaining, completion: completion)
            return
        }
        
        let productUrl = "https://raw.githubusercontent.com/plguo/Terra-Recycle-Wiki/master/products/" + filename
        Alamofire.request(productUrl).responseString { [weak self] (response) in
            if (response.result.isSuccess) {
                let lines = (response.result.value! as NSString).components(separatedBy: "\n")
                
                var productName = ""
                var tableStarted = false
                for line in lines {
                    if (line.hasPrefix("# ")) {
                        let productBegin = line.index(line.startIndex, offsetBy: 2)
                        productName = line.substring(from: productBegin).lowercased()
                    } else if (line == "") {
                        tableStarted = false
                    } else if (line == "| --- | --- |") {
                        tableStarted = true
                    } else if (tableStarted && productName == name) {
                        let row = line.components(separatedBy: "|")
                        let recycleCategory = row[2].trimmingCharacters(in: .whitespaces).lowercased()
                        
                        completion(originalName, recycleCategory)
                        return
                    }
                }
            }
            
            self?.fetchProduct(remaining, completion: completion)
        }
    }
}
