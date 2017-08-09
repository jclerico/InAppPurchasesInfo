//
//  ViewController.swift
//  daily-dose
//
//  Created by Mark Price on 7/21/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HomeVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var removeAdsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAds()
    }
    
    func setupAds() {
        //Check against userdefaults to see if the key we set when the user purchases the IAP exists or not. if so, remove bannerView and removeAdsBtn from the View, and if not show ad as normal.
        if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
            removeAdsBtn.removeFromSuperview()
            bannerView.removeFromSuperview()
        } else {
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    
    @IBAction func restoreBtnPressed(_ sender: Any) {
        //If restorePurchases returns true for success variable proceed to setupAds() - basically same as removeAdsPressed process.
        PurchaseManager.instance.restorePurchases { success in
            if success {
                self.setupAds()
            }
        }
    }
    
    //Whats going to happen in the func: going to call purchaseRemoveAds, in there we are storing the callback we passed in (transactionComplete). When payment is done, we call transactionComplete with true or false, which passes the boolean into the 'success' variable below
    @IBAction func removeAdsPressed(_ sender: Any) {
        //show a loading spinner ActivityIndicator
        PurchaseManager.instance.purchaseRemoveAds { success in
            //dismiss spinner
            if success {
                self.bannerView.removeFromSuperview()
                self.removeAdsBtn.removeFromSuperview()
            } else {
                //show message to the user
            }
        }
    }
}

