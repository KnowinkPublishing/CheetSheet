//
//  QuizeltViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/25/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import Alamofire

struct QuizeltModel {

    typealias quizletClosure = (_ bSuccess: Bool, _ arrData: Array<CS_Quizlet>, _ dictResultsData: Dictionary<String, Any>, _ strErrMsg: String) -> Void

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    func getSearchResults(_ strToSearch: String, _ pageNum: Int, completion:@escaping quizletClosure) {

        let dictParams = ["client_id": myConfig.quizletID, "q": strToSearch, "whitespace": "1", "per_page": "100", "page": String(pageNum)]
        
        let myURLComponents = myController.apiManager.makeURLComponents("https", myConfig.quizletBaseURL, myConfig.quizletPath, dictParams)
        
        if let myURL = myURLComponents.url {
            
            Alamofire.request(myURL).responseJSON(completionHandler: { response in
                
                if let dictJSON = response.result.value as? Dictionary<String, Any> {
                    
                    if let arrQuizlets = dictJSON["sets"] as? Array<Dictionary<String, Any>> {
                        
                        var dictResultsData: Dictionary<String, Any> = [:]
                        if let totalResults = dictJSON["total_results"] as? NSNumber, let totalPages = dictJSON["total_pages"] as? NSNumber, let page = dictJSON["page"] as? NSNumber {
                            dictResultsData["totalResults"] = totalResults
                            dictResultsData["totalPages"] = totalPages
                            dictResultsData["page"] = page
                        }
                        
                        var arrData = [CS_Quizlet]()
                        for dictQuizlet in arrQuizlets {
                            
                            let thisQuizlet = CS_Quizlet()
                            thisQuizlet.quizletID = dictQuizlet["id"] as? String ?? ""
                            thisQuizlet.quizletTitle = dictQuizlet["title"] as? String ?? ""
                            thisQuizlet.quizletCreatedBy = dictQuizlet["created_by"] as? String ?? ""
                            
                            if let createdTimestamp = dictQuizlet["created_date"] as? TimeInterval {
                                thisQuizlet.quizletCreatedDate = self.myController.dateManager.convertTimeStampToString(createdTimestamp)
                            } else {
                                thisQuizlet.quizletCreatedDate = self.myController.dateManager.dateToString(Date(), "MM/dd/YYYY")
                            }
                            
                            if let modifiedTimeStamp = dictQuizlet["modified_date"] as? TimeInterval {
                                thisQuizlet.quizletModifiedDate = self.myController.dateManager.convertTimeStampToString(modifiedTimeStamp)
                            } else {
                                thisQuizlet.quizletModifiedDate = self.myController.dateManager.dateToString(Date(), "MM/dd/YYYY")
                            }
                            
                            thisQuizlet.quizletDescription = dictQuizlet["description"] as? String ?? "No description provided."
                            thisQuizlet.quizletTermCount = dictQuizlet["term_count"] as? String ?? ""
                            thisQuizlet.quizletURL = dictQuizlet["url"] as? String ?? ""
                            
                            arrData.append(thisQuizlet)
                        }
                        
                        completion(true, arrData, dictResultsData, "")
                        
                    } else {
                        
                        completion(false, [], [:], "There was an error with the Quizlet search")
                    }
                    
                }
                
            })
            
        }
        
        /*
        myController.apiManager.makeJSONCall("https", myConfig.quizletBaseURL, myConfig.quizletPath, dictParams, [:], [:], completion: {(_, dictJSON, _, _) in

            if let arrQuizlets = dictJSON["sets"] as? Array<Dictionary<String, Any>> {

                var dictResultsData: Dictionary<String, Any> = [:]
                if let totalResults = dictJSON["total_results"] as? NSNumber, let totalPages = dictJSON["total_pages"] as? NSNumber, let page = dictJSON["page"] as? NSNumber {
                    dictResultsData["totalResults"] = totalResults
                    dictResultsData["totalPages"] = totalPages
                    dictResultsData["page"] = page
                }

                var arrData = [CS_Quizlet]()
                for dictQuizlet in arrQuizlets {

                    let thisQuizlet = CS_Quizlet()
                    thisQuizlet.quizletID = dictQuizlet["id"] as? String ?? ""
                    thisQuizlet.quizletTitle = dictQuizlet["title"] as? String ?? ""
                    thisQuizlet.quizletCreatedBy = dictQuizlet["created_by"] as? String ?? ""

                    if let createdTimestamp = dictQuizlet["created_date"] as? TimeInterval {
                        thisQuizlet.quizletCreatedDate = self.myController.dateManager.convertTimeStampToString(createdTimestamp)
                    } else {
                        thisQuizlet.quizletCreatedDate = self.myController.dateManager.dateToString(Date(), "MM/dd/YYYY")
                    }

                    if let modifiedTimeStamp = dictQuizlet["modified_date"] as? TimeInterval {
                        thisQuizlet.quizletModifiedDate = self.myController.dateManager.convertTimeStampToString(modifiedTimeStamp)
                    } else {
                        thisQuizlet.quizletModifiedDate = self.myController.dateManager.dateToString(Date(), "MM/dd/YYYY")
                    }

                    thisQuizlet.quizletDescription = dictQuizlet["description"] as? String ?? "No description provided."
                    thisQuizlet.quizletTermCount = dictQuizlet["term_count"] as? String ?? ""
                    thisQuizlet.quizletURL = dictQuizlet["url"] as? String ?? ""

                    arrData.append(thisQuizlet)
                }

                completion(true, arrData, dictResultsData, "")

            } else {

                completion(false, [], [:], "There was an error with the Quizlet search")
            }

        })
         */
    }

}
