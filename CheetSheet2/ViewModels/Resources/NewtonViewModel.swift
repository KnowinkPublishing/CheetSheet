//
//  NewtonViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/5/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import Alamofire

struct NewtonModel {

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    typealias newtonEquationCompletion = (_ bSuccess: Bool, _ dictJSON: Dictionary<String, Any>, _ strErrMsg: String) -> Void

    func getEquationResults(_ strEquation: String, _ strOperation: String, completion: @escaping newtonEquationCompletion) {

        //construct path
        let strPath = "/" + strOperation + "/" + strEquation
        let myURLComponents = myController.apiManager.makeURLComponents("https", myConfig.newtonBaseURL, strPath, [:])
        if let myURL = myURLComponents.url {
            Alamofire.request(myURL).responseJSON(completionHandler: { response in
                
                if let dictJSON = response.result.value as? Dictionary<String, Any> {
                    completion(true, dictJSON, "")
                } else {
                    completion(false, [:], "There was a problem with the JSON request.")
                }
                
            })
        }
        
        /*
        myController.apiManager.makeJSONCall("https", myConfig.newtonBaseURL, strPath, [:], [:], [:], completion: {(bSuccess, dictJSON, _, _) in

            if bSuccess {
                completion(bSuccess, dictJSON, "")
            } else {
                completion(bSuccess, dictJSON, "There was a problem with the JSON request.")
            }
        })
        */

    }
}
