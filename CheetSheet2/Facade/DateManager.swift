//
//  DateManager.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/8/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation

struct DateManager {

    func dateToString(_ dtToFormat: Date, _ strFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = strFormat
        return formatter.string(from: dtToFormat)
    }

    func convertTimeStampToString(_ timestamp: TimeInterval) -> String {

        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM/dd/YYYY" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
}
