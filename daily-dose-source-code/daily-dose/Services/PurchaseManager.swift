//
//  PurchaseManager.swift
//  daily-dose
//
//  Created by Mark Price on 7/21/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

typealias CompletionHandler = (_ success: Bool) -> ()

import Foundation
import StoreKit

//If working with In-App Purchases (IAP), need to work with below Protocols
class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //Creating Singleton
    static let instance = PurchaseManager()
    
    //Store IAP Reference you created in ItunesConnect
    let IAP_REMOVE_ADS = "com.devslopes.daily.dose.remove.ads"
    
    //Variables
    var productsRequest: SKProductsRequest!
    var products = [SKProduct]()
    //Store Completion Handler
    var transactionComplete: CompletionHandler?
    
    //Cant make purchase unless the app has spoken to appstore and downloaded product IDs for the specific app
    func fetchProducts() {
        //Fetch specific products for this app
        let productIds = NSSet(object: IAP_REMOVE_ADS) as! Set<String>
        //Save request
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        //Set delegate and start.
        productsRequest.delegate = self
        productsRequest.start()
        //Delegate will call productsRequest once its done.
    }
    
    func purchaseRemoveAds(onComplete: @escaping CompletionHandler) {
        //First, make sure user can make a payment, and at least 1 product exists.
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            //Store completion handler here so VC knows when transaction is complete
            transactionComplete = onComplete
            //Grab the product we want from the products Array
            let removeAdsProduct = products[0]
            //Create payment for product. Payment is what processes the product.
            //'..add(self)' is adding PurchaseManager as an observer
            //'..add(payment)' is adding payment to start processing payment request
            let payment = SKPayment(product: removeAdsProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            onComplete(false)
        }
    }
    
    func restorePurchases(onComplete: @escaping CompletionHandler) {
        //If user can make payments, proceed
        if SKPaymentQueue.canMakePayments() {
            //Store callback handler
            transactionComplete = onComplete
            //Add self as an observer and restore completed transactions
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            onComplete(false)
        }
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //If products are found, start working with them and store them in products.
        if response.products.count > 0 {
            print(response.products.debugDescription)
            products = response.products
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //Iterate through all transactions that have actively been going through when the callback (updatedTransactions) is called.
        //Then go through switch cases.
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                //Let service know transaction is done
                //If product Identifier coming through transaction euqals the remove ads product identifier, complete the in-app purchase and store a key in userdefaults with boolean 'true' so app doesnt dispaly adds on launch.
                //If transaction is successful, call transactionComplete and say true. Now VC knows transaction is complete
            SKPaymentQueue.default().finishTransaction(transaction)
            if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                transactionComplete?(true)
            }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionComplete?(false)
                break
            case .restored:
                //If transaction exists (as purchased before) then proceed to remove ads for user.
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                    UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                }
                transactionComplete?(true)
            default:
                transactionComplete?(false)
                break
            }
        }
    }
}
