//
//  TipMachine.swift
//  Playlist Maker
//
//  Created by Tomn on 03/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit
import StoreKit

/// Everything that concerns money…
class TipMachine: NSObject {
    
    static let timesBeforeShowingRatings = 3
    
    /// it is me
    static let contactURL = "https://twitter.com/tomn94"
    
    /// App Store redirection to leave a review
    static let appStoreURL = "itms-apps://itunes.apple.com/app/id1278103627?action=write-review"
    
    fileprivate static let productIds = ["fr.tomn.PlaylistsMaker.TipTier1", "fr.tomn.PlaylistsMaker.TipTier2",
                                         "fr.tomn.PlaylistsMaker.TipTier4", "fr.tomn.PlaylistsMaker.TipTier9"]
    
    fileprivate var products = [SKProduct]()
    
    var parentVC: UIViewController?
    
    
    /// In-App App Store Rating
    class func askForReview() {
        
        if DataStore.sortFinishedCount >= TipMachine.timesBeforeShowingRatings {
            SKStoreReviewController.requestReview()
        }
    }
    
    
    func showInfo(from parentVC: UIViewController) {
        
        let alert = UIAlertController(title: "Playlists Maker",
                                      message: "Made by Thomas Naudet",
                                      preferredStyle: .alert)
        if SKPaymentQueue.canMakePayments() {
            alert.addAction(UIAlertAction(title: "❤️ Give a Tip", style: .default) { _ in
                self.presentOptions(from: parentVC)
            })
        }
        alert.addAction(UIAlertAction(title: "⭐️ Leave a Review", style: .default) { _ in
            UIApplication.shared.open(URL(string: TipMachine.appStoreURL)!,
                                      options: [:])
        })
        alert.addAction(UIAlertAction(title: "✉️ Contact", style: .default) { _ in
            UIApplication.shared.open(URL(string: TipMachine.contactURL)!,
                                      options: [:])
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentVC.present(alert, animated: true)
    }
    

    func presentOptions(from parentVC: UIViewController) {
        
        guard SKPaymentQueue.canMakePayments() else {
            
            let alert = UIAlertController(title: "Ow, too bad!",
                                          message: "You cannot make purchases. Check Restrictions Settings on your device.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            parentVC.present(alert, animated: true)
            return
        }
        
        self.parentVC = parentVC
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let request = SKProductsRequest(productIdentifiers: Set(TipMachine.productIds))
        request.delegate = self
        request.start()
    }
    
}

extension TipMachine: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest,
                         didReceive response: SKProductsResponse) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard !response.products.isEmpty else {
            
            let alert = UIAlertController(title: "Ow, too bad!",
                                          message: "No In-App Purchases are currently available.\nCheck back later!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            parentVC?.present(alert, animated: true)
            return
        }
        
        products = response.products
        products.sort { product1, product2 in
            product1.price.compare(product2.price) == .orderedAscending
        }
        
        let alert = UIAlertController(title: "That's nice!",
                                      message: "How do you want to reward me for my work?",
                                      preferredStyle: .alert)
        
        for product in products {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale      = product.priceLocale
            if let price = formatter.string(from: product.price) {
                
                let title = product.localizedTitle + " (" + price + ")"
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                    
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment)
                }))
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentVC?.present(alert, animated: true)
    }
    
    func request(_ request: SKRequest,
                 didFailWithError error: Error) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let alert = UIAlertController(title: "Ow, too bad!",
                                      message: "Unable to retrieve available In-App Purchases.\n\n"
                                                + error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        parentVC?.present(alert, animated: true)
    }
    
}
