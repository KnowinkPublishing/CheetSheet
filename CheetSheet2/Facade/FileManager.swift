//
//  FileManager.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/4/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit

struct LocaleFileManager {

    let myFileManager = FileManager.default

    func storeImageInDocumentsDirectory(_ imageData: Data, _ strImgName: String, _ strExtension: String, completion: (_ result: Bool, _ strFilePath: String)->Void) {

        //get doc directory
        let documentsDirectory = myFileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let strFileName = "\(strImgName).\(strExtension)"
        var result = true

        //create path for file
        let fileURL = documentsDirectory.appendingPathComponent(strFileName)

        //remove the file if it exists
        if myFileManager.fileExists(atPath: fileURL.absoluteString) {
            try! myFileManager.removeItem(atPath: fileURL.absoluteString)
        }

        do {
            // writes the image data to disk
            try imageData.write(to: fileURL)
            print("\n=================\n\nFile Saved\n\n\n=================")
        } catch {
            print("\n=================\n\nError Saving File\n\n\n=================")
            result = false
        }

        completion(result, fileURL.absoluteString)

    }

    func getImageFromDocumentsDirectory(_ strFileName: String) -> Dictionary<String, Any> {

        var bSuccess = false
        var dictResults: Dictionary<String, Any> = [:]

        let imgToUse: UIImage?
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(strFileName)
            imgToUse    = UIImage(contentsOfFile: imageURL.path)

            if let imgToReturn = imgToUse {
                dictResults["Image"] =  imgToReturn
                bSuccess = true
            }
        }

        dictResults["Success"] = bSuccess
        return dictResults
    }
}
