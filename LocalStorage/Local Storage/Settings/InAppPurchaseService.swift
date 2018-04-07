//
//  InAppPurchaseService.swift
//  localstorage
//
//  Created by Günther Eberl on 07.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
import StoreKit


class InAppPurchaseService: NSObject {
    
    // Make this a singleton.
    private override init() {}
    static let shared = InAppPurchaseService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = [InAppPurchase.tipSmall.rawValue,
                             InAppPurchase.tipMedium.rawValue,
                             InAppPurchase.tipBig.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        self.paymentQueue.add(self)
    }
    
    func purchase(product: InAppPurchase) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue}).first else { return }
        let payment = SKPayment(product: productToPurchase)
        self.paymentQueue.add(payment)
    }
}

extension InAppPurchaseService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        
        print(response.invalidProductIdentifiers)  // TODO this has all my stuff inside it
        print(response.products)  // TODO this is [], because products have not been submitted with new version
//        for product in response.products {
//            print(product.localizedDescription)
//            print(product.localizedTitle)
//            print(product.productIdentifier)
//        }
    }
}

extension InAppPurchaseService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
            case .deferred: return "deferred"
            case .failed: return "failed"
            case .purchased: return "purchased"
            case .purchasing: return "purchasing"
            case .restored: return "restored"
        }
    }
}
