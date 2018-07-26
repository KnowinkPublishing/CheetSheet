//
//  APIManager.swift
//  CheatSheet
//
//  Created by Steven Suranie on 11/13/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class APIManager: NSObject {

    typealias jsonClosure = (_ bSuccess: Bool, _ dictJSON: Dictionary<String, Any>, _ jsonData: Data, _ strMsg: String) -> Void
    typealias imageClosure = (_ bSuccess: Bool, _ imgFromURL: UIImage, _ strMsg: String) -> Void

    let myConfig = csConfig()

    func makeJSONCall(_ scheme: String, _ host: String, _ path: String, _ params: [String: String], _ postData: [String: String], _ headerData: [String: String], completion:@escaping jsonClosure) {

        let myURLComps = makeURLComponents(scheme, host, path, params)

        //request
        if let myURL = myURLComps.url {

            var myURLRequest = URLRequest(url: myURL)

            //check to see if we need to pass any post data
            if postData.count > 0 {

                let strPostData = postData.map {$0 + "=" + $1}.joined(separator: "&")

                //convert string to data
                let postData = strPostData.data(using: String.Encoding.utf8)!

                //convert data to base 64
                let post64Encoded = postData.base64EncodedData()

                //this would be for a user name/password
                myURLRequest.httpMethod = "POST"
                myURLRequest.setValue("Basic \(post64Encoded)", forHTTPHeaderField: "Authorization")

            }

            let dataTask = URLSession.shared.dataTask(with: myURLRequest) { (data, response, error) in

                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Error with data")
                    return
                }

                if let response = response as? HTTPURLResponse {

                    if response.statusCode == 200 {

                        do {

                            let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                            //print(dictJSON ?? "Something borked!")

                            if let dictJSON = jsonObj {
                                completion(true, dictJSON, data, "")
                            }

                        } catch {

                        }

                    } else {
                        print("Response error: \(response.statusCode)\n\(response.description)")
                    }
                } else {
                    print("Error with response")
                    return
                }
            }

            dataTask.resume()
        }

    }

    // MARK: - URL Components

    func makeURLComponents(_ scheme: String, _ host: String, _ path: String, _ params: [String: String]) -> URLComponents {

        var myURLComps = URLComponents()
        myURLComps.scheme = scheme
        myURLComps.host = host
        myURLComps.path = path

        if params.count > 0 {
            var arrQueryItems = [URLQueryItem]()
            for (key, value) in params {
                arrQueryItems.append(URLQueryItem(name: key, value: value))
            }
            myURLComps.queryItems = arrQueryItems
        }

        return myURLComps
    }

    // MARK: - Get Image From URL
    func getImageFromURL(_ strURL: String, completion:@escaping imageClosure) {

        if let imgURL = URL(string: strURL) {

            DispatchQueue.global(qos: .userInitiated).async {

                let imageData: NSData = NSData(contentsOf: imgURL)!
                let image = UIImage(data: imageData as Data)

                if let imgFromURL = image {
                    completion(true, imgFromURL, "")
                } else {
                    completion(false, image!, "")
                }

            }
        }

    }

    // MARK: - POST Data

    func postData(dictData: Dictionary<String, Any>, method: String, completion: @escaping (_ message: Data) -> Void) {

        //create the url
        var myURLComp = URLComponents()
        myURLComp.scheme = "http"
        myURLComp.host = "www.martiantribe.com"
        myURLComp.path = "cheetsheet/cs_services.php"
        let myQueryItem = URLQueryItem(name: "method", value: "register")
        myURLComp.queryItems = [myQueryItem]

        //set up the request

        //if let myURL = myURLComp.url {

        let myURL = URL(string: "http://www.martiantribe.com/cheetsheet/cs_services.php?method=\(method)")

            var myRequest = URLRequest(url: myURL!)

            //post data
            var strPostParams = " "
            for(key, value) in dictData {
                strPostParams = strPostParams + "\(key)=\(value)&"
            }

            myRequest.httpMethod = "POST"
            myRequest.httpBody = strPostParams.data(using: .utf8)
            myRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

            let myDataTask = URLSession.shared.dataTask(with: myRequest) { (data, response, error) in

                if error != nil {
                    print(error!.localizedDescription)
                }

                guard let data = data, let response = response  else {
                    print("error with data or response")
                    return
                }

                completion(data)

                /*
                do {
                    
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let strData = String(data: data, encoding: String.Encoding.utf8) as String!
                    
                    
                    
                    if let dictJSON = jsonResponse as? [String: Any] {
                        //print("Dictionary:\(dictJSON)\n\(String(describing: strData))")
                    } else {
                        //print("JSON Response:\(jsonResponse)")
                    }
                    
                    
                } catch {
                    let strData = String(data: data, encoding: String.Encoding.utf8) as String!
                    print("json error: \(error.localizedDescription)\n\(String(describing: strData))")
                }
                */

            }

            myDataTask.resume()

    }

    // MARK: - Get Data From URL
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }

}
