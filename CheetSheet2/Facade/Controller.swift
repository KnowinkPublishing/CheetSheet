//
//  Controller.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation

class Controller {

    //because we have a private initializer this is the only way to create the singleton
    static let sharedInstance = Controller()

    let alert = AlertManager()
    let dataManager = DataManager()
    let dateManager = DateManager()
    let apiManager = APIManager()
    let validationManager = ValidationManager()
    let locationManager = LocationManager()
    let fileManager = LocaleFileManager()
    let animationManager = AnimationManager()
    let soundManager = SoundManager()

    //this prevents others from using the default () to initialize the controller
    private init() {}

}
