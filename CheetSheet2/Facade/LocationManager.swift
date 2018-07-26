//
//  LocationManager.swift
//  CheatSheet
//
//  Created by Steven Suranie on 11/19/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationManager {

    func getZipCodeAndLocationStringFromLocation (_ userLocation: CLLocation, completion: (_ strLocation: String, _ strZipCode: String)->Void) {

        //get user zip from location
        let geoCoder = CLGeocoder()
        var strLocation = "@40.2066434,-75.4869032,15z"
        var strZipCode = "Unknown"

        //convert CLLocation to string for storage
        strLocation = "\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)"

        geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placeMarks, _) in

            let arrPlaceMarks = placeMarks! as [CLPlacemark]
            if arrPlaceMarks.count > 0 {
                strZipCode = arrPlaceMarks.first!.postalCode!
            }

        })

        completion(strLocation, strZipCode)
    }

}
