//
//  InAppPurchaseService.swift
//  localstorage
//
//  Created by Günther Eberl on 07.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
import StoreKit
import os.log


class InAppPurchaseService: NSObject {
    
    // Enforce this being a singleton.
    private override init() {}
    static let shared = InAppPurchaseService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        os_log("getProducts", log: logPurchase, type: .debug)
        
        let productIds: Set = [InAppPurchase.tipSmall.rawValue,
                               InAppPurchase.tipMedium.rawValue,
                               InAppPurchase.tipBig.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
        
        self.paymentQueue.add(self)
    }
    
    func purchase(product: InAppPurchase) {
        os_log("purchase", log: logPurchase, type: .debug)
        
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue}).first else { return }
        let payment = SKPayment(product: productToPurchase)
        self.paymentQueue.add(payment)
    }
}

extension InAppPurchaseService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        os_log("productsRequest", log: logPurchase, type: .debug)
        
        self.products = response.products
    }
}

extension InAppPurchaseService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        os_log("paymentQueue", log: logPurchase, type: .debug)
        
        for transaction in transactions {
            os_log("Item: %@ -> Status: %@", log: logPurchase, type: .info,
                   transaction.payment.productIdentifier, transaction.transactionState.status())
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
            case .deferred: return "Deferred"
            case .failed: return "Failed"
            case .purchased: return "Purchased"
            case .purchasing: return "Purchasing"
            case .restored: return "Restored"
        }
    }
}
