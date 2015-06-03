//
//  HereViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HereViewController: AbstractViewController, SpotDetailViewDelegate, ScheduleViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var scheduleViewController : ScheduleViewController?
    var firstUseMessageVC : HereFirstUseViewController?
    var detailView: SpotDetailView
    
    var statusBar : UIView
    var checkinButton : UIButton
    var searchField : UITextField

    var activeSpot : ParkingSpot?
    
    var delegate : HereViewControllerDelegate?
    var searchDelegate : SearchViewControllerDelegate?

    init() {
        detailView = SpotDetailView()
        statusBar = UIView()
        checkinButton = UIButton()
        searchField = UITextField()
        searchField.clearButtonMode = UITextFieldViewMode.Always
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = TouchForwardingView()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (Settings.firstMapUse()) {
            showFirstUseMessage()
            Settings.setFirstMapUsePassed(true)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("HereViewController disappeared")
        hideScheduleView()
        hideSpotDetails()
    }
    
    func setupViews () {

        detailView.delegate = self
        view.addSubview(detailView)
        
        statusBar.backgroundColor = Styles.Colors.statusBar
        view.addSubview(statusBar)
        
        checkinButton.setImage(UIImage(named: "btn_checkin_active"), forState: UIControlState.Normal)
        checkinButton.setImage(UIImage(named: "btn_checkin"), forState: UIControlState.Disabled)
        checkinButton.addTarget(self, action: "checkinButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        checkinButton.enabled = false
        view.addSubview(checkinButton)
        
        searchField.backgroundColor = Styles.Colors.cream2
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = Styles.Colors.beige1.CGColor
        searchField.font = Styles.FontFaces.light(22)
        searchField.textColor = Styles.Colors.midnight2
        searchField.textAlignment = NSTextAlignment.Center
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.Dark
        searchField.keyboardType = UIKeyboardType.WebSearch
        view.addSubview(searchField)

    }
    
    func setupConstraints() {
        
        statusBar.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        detailView.snp_makeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_makeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-20)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        searchField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(40)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.view).with.offset(12)
            make.right.equalTo(self.view).with.offset(-12)
        }
        
    }
    
    
    func showFirstUseMessage() {
        
        firstUseMessageVC = HereFirstUseViewController()
        
        self.addChildViewController(firstUseMessageVC!)
        self.view.addSubview(firstUseMessageVC!.view)
        firstUseMessageVC!.didMoveToParentViewController(self)
        
        firstUseMessageVC!.view.snp_makeConstraints({ (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissFirstUseMessage")
        firstUseMessageVC!.view.addGestureRecognizer(tap)
        
        firstUseMessageVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.firstUseMessageVC!.view.alpha = 1.0
        })
    }
    
    func dismissFirstUseMessage() {
        
        if let firstUseMessageVC = self.firstUseMessageVC {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                firstUseMessageVC.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    firstUseMessageVC.removeFromParentViewController()
                    firstUseMessageVC.view.removeFromSuperview()
                    firstUseMessageVC.didMoveToParentViewController(nil)
                    self.firstUseMessageVC = nil
            })
            
        }
        
        
    }
    
    func scheduleButtonTapped() {
        showScheduleView(activeSpot)
    }
    
    func showScheduleView(spot : ParkingSpot?) {
        
        if spot != nil {
            self.scheduleViewController = ScheduleViewController(spot: spot!)
            self.view.addSubview(self.scheduleViewController!.view)
            self.scheduleViewController!.willMoveToParentViewController(self)
            self.scheduleViewController!.delegate = self
            self.scheduleViewController!.view.hidden = true
            
            self.scheduleViewController!.view.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(self.view.snp_bottom)
                make.size.equalTo(self.view)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
            })
            
            self.scheduleViewController!.view.layoutIfNeeded()
            
            
            self.scheduleViewController!.view.hidden = false
            self.scheduleViewController!.view.snp_remakeConstraints({ (make) -> () in
                make.edges.equalTo(self.view)
            })
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.scheduleViewController!.view.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    //
            })
            
            
        }
    }
    
    
    func hideScheduleView () {
        
        if(self.scheduleViewController == nil) {
            return
        }
        
        self.scheduleViewController!.view.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.view.snp_bottom)
            make.size.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scheduleViewController!.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                
                self.scheduleViewController!.view.removeFromSuperview()
                self.scheduleViewController!.willMoveToParentViewController(nil)
                self.scheduleViewController!.removeFromParentViewController()
                self.scheduleViewController = nil
        })
        
    }
    
    func checkinButtonTapped() {
        
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
                
        SpotOperations.checkin(activeSpot!.identifier, completion: { (completed) -> Void in
            
            Settings.saveCheckInData(self.activeSpot!, time: NSDate())
            
            if (Settings.notificationTime() > 0) {
                Settings.cancelAlarm()
                Settings.scheduleAlarm(NSDate(timeIntervalSinceNow: self.activeSpot!.availableTimeInterval() - (30 * 60)))
            }
            
            SVProgressHUD.dismiss()
            self.delegate?.loadMyCarTab()
            
        })
        
        
    }
    
    
    func showSpotDetails (completed : ()) {
        
        if (activeSpot != nil) {
            println("selected spot : " + activeSpot!.identifier)
        }
        
        detailView.titleLabel.text = activeSpot?.name
        
        detailView.availableTimeLabel.text = activeSpot?.availableHourString()
        
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(0)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_remakeConstraints {
            (make) -> () in
            make.centerY.equalTo(self.detailView.snp_top)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        checkinButton.enabled = !Settings.checkedIn()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    
    func hideSpotDetails (completed : () ) {
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-20)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        checkinButton.enabled = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(false)
        SearchOperations.searchByStreetName(textField.text, completion: { (results) -> Void in
            
            let today = DateUtil.dayIndexOfTheWeek()
            var date : NSDate = NSDate()
            
            self.searchDelegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        searchDelegate?.clearSearchResults()
        return true
    }
    
    
}


protocol HereViewControllerDelegate {
    func loadMyCarTab()
}
