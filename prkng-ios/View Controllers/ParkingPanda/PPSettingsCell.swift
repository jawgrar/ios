//
//  PPSettingsCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-21.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation

//MARK: This class is THE instantiation of the ParkingPanda settings cell, so that we can change it independently of the SettingsViewController.

class PPSettingsCell: SettingsCell {
    
    override var switchValue: Bool? {
        get {
            let ppCreds = Settings.getParkingPandaCredentials()
            return ppCreds.0 != nil && ppCreds.1 != nil
        }
        set(value) {
            //do nothing! Muahaha! Converting a get/set property to a get-only property!
        }
    }
    
    init() {
        //TODO: the text below should be localized
        super.init(cellType: .Switch, switchValue: false, titleText: "Parking Panda", subtitleText: "Use ParkingPanda to reserve and pay for a parking spot in a garage or lot.")
        self.selectorsTarget = self
        self.canSelect = true
        self.cellSelector = "wasSelected"
        let ppCreds = Settings.getParkingPandaCredentials()
        self.switchValue = ppCreds.0 != nil && ppCreds.1 != nil
    }
    
    var tableViewCell: UITableViewCell {
        let cell = SettingsSwitchCell()

        cell.titleText = self.titleText
        cell.subtitleText = self.subtitleText
        cell.switchOn = self.switchValue ?? false
        cell.selector = "ppSwitched"
        cell.selectorsTarget = self
        
        //add a right accessory
        cell.accessoryType = .DisclosureIndicator

        return cell
    }
    
    func ppSwitched() {
        if switchValue == true {
            //if we're switching OFF then log out
            ParkingPandaOperations.logout()
        } else {
            //if we're switching ON then do the same thing as a selection
            wasSelected()
        }
    }
        
    func wasSelected() {
        
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.show()
        
        ParkingPandaOperations.login(username: nil, password: nil, includeCreditCards: true) { (user, error) -> Void in
            
            if user != nil {
              
                ParkingPandaOperations.getCreditCards(user!) { (creditCards, error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let ppSettingsVC = PPSettingsViewController(user: user!, creditCards: creditCards)
                        ppSettingsVC.present()
                    })
                }
                
            } else {
                
                if let ppError = error {
                    switch (ppError.errorType) {
                    case .API, .Internal:
                        ParkingPandaOperations.logout()
                        //TODO: show a login/create account screen
                        let ppIntroVC = PPIntroViewController()
                        ppIntroVC.present()
                    case .None, .Network:
                        //TODO: show an error popup
                        break
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
            })

        }
        
    }
    
}
