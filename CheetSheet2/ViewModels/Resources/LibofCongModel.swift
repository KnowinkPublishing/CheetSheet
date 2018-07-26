//
//  LibofCongModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/11/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct LibOfCongressModel {

    typealias LocSearchClosure = (_ bSuccess: Bool, _ arrLOCObjs: Array<locObj>, _ strMsg: String) -> Void
    typealias LocMediaImageClosure = (_ bSuccess: Bool, _ imgMedia: UIImage, _ strErrMsg: String) -> Void

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    //q=boston&st=gallery&fo=json

    func searchLOC(_ strToSearch: String, completion:@escaping LocSearchClosure) {

        let dictParams = ["q": strToSearch, "st": "gallery", "fo": "json"]
        var arrLOCObjs = [locObj]()
        
        let myURLComponents = myController.apiManager.makeURLComponents("https", myConfig.locBaseURL, myConfig.locBasePath, dictParams)
        
        if let myURL = myURLComponents.url {
            
            Alamofire.request(myURL).responseJSON(completionHandler: { response in
                
                if let dictJSON = response.result.value as? Dictionary<String, Any> {
                    
                    if let arrResults = dictJSON["results"] as? Array<Dictionary<String, Any>> {
                        
                        if arrResults.count > 0 {
                            
                            //convert to data and create objects
                            for dictThisResult in arrResults {
                                
                                let dictImage = dictThisResult["image"]
                                
                                let decoder = JSONDecoder()
                                let locData = try! JSONSerialization.data(withJSONObject: dictThisResult, options: .prettyPrinted)
                                let locImageData = try! JSONSerialization.data(withJSONObject: dictImage, options: .prettyPrinted)
                                var thisLOCObj = try! decoder.decode(locObj.self, from: locData)
                                let thisLOCImage = try! decoder.decode(locObjImg.self, from: locImageData)
                                thisLOCObj.image = thisLOCImage
                                
                                arrLOCObjs.append(thisLOCObj)
                                
                                completion(true, arrLOCObjs, "")
                                
                            }
                            
                        } else {
                            completion(false, arrLOCObjs, "The search for \(strToSearch) produced no results.")
                        }
                        
                    } else {
                        completion(false, arrLOCObjs, "There was an error in getting the Library of Congress results.")
                    }
                }
                
            })
        }
        
        /*
        myController.apiManager.makeJSONCall("https", myConfig.locBaseURL, myConfig.locBasePath, dictParams, [:], [:], completion: {(_, dictJSON, _, _) in

            if let arrResults = dictJSON["results"] as? Array<Dictionary<String, Any>> {

                if arrResults.count > 0 {

                    //convert to data and create objects
                    for dictThisResult in arrResults {

                        let dictImage = dictThisResult["image"]

                        let decoder = JSONDecoder()
                        let locData = try! JSONSerialization.data(withJSONObject: dictThisResult, options: .prettyPrinted)
                        let locImageData = try! JSONSerialization.data(withJSONObject: dictImage, options: .prettyPrinted) 
                        var thisLOCObj = try! decoder.decode(locObj.self, from: locData)
                        let thisLOCImage = try! decoder.decode(locObjImg.self, from: locImageData)
                        thisLOCObj.image = thisLOCImage

                        arrLOCObjs.append(thisLOCObj)

                        completion(true, arrLOCObjs, "")

                    }

                } else {
                    completion(false, arrLOCObjs, "The search for \(strToSearch) produced no results.")
                }

            } else {
                completion(false, arrLOCObjs, "There was an error in getting the Library of Congress results.")
            }

        })
        */
    }

    func getMediaURL(_ strURL: String, completion:@escaping LocMediaImageClosure) {

        myController.apiManager.getImageFromURL(strURL, completion: {(bSuccess, imgFromURL, _) in

            if bSuccess {
                completion(true, imgFromURL, "")
            } else {
                completion(false, imgFromURL, "There was an error")
            }
        })
    }
}
