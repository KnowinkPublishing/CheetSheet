//
//  CS_PBS.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/20/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

struct pbsLesson: Codable {

    let title: String
    let uri: String
    let description: String
    let gradeRanges: String

    enum CodingKeys: String, CodingKey {
        case title
        case uri
        case description
        case gradeRanges = "grade_ranges"
    }

}
