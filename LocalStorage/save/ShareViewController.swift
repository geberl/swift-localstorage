//
//  ShareViewController.swift
//  save
//
//  Created by Günther Eberl on 02.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        print("isContextValid")
        print("contentText: " + contentText) // is title of page in Safari
        // print("placeholder: " + placeholder) // is nil
        
        // print(extensionContext ?? "nothing contained")
        // Optional(<NSExtensionContext: 0x1c00acde0> - UUID: FF86C0C3-73FA-4D61-B9EC-85758E6FD665 - _isHost: NO _isDummyExtension:NO inputItems: ("<NSExtensionItem: 0x1c02 ...
        // https://developer.apple.com/documentation/foundation/nsextensioncontext
        
        let containedItems = extensionContext?.inputItems as! [NSExtensionItem]
        for containedItem in containedItems {
            // print(containedItem.userInfo ?? "no info")  // messy
            // print(containedItem.attributedContentText ?? "no content text") // contentText with font info
            let itemAttachments = containedItem.attachments
            for itemAttachment in itemAttachments! {
                //print(itemAttachment)
                // <NSItemProvider: 0x1c40c3aa0> {types = ("public.url")}
                
                print((itemAttachment as AnyObject).registeredTypeIdentifiers)
                // ["public.url"]
                
                (itemAttachment as AnyObject).loadItem(forTypeIdentifier: "public.url",
                                                       options: [:],
                                                       completionHandler: self.myCompletionHandler)
            }
        }
        // https://developer.apple.com/documentation/foundation/nsextensionitem
        
        return true
    }
    
    func myCompletionHandler(secCoding: NSSecureCoding?, err: Error!) -> Void {
        print("myCompletionHandler")
        
        print(secCoding ?? "no coding contained")
        // this is the actual url (but not sure if as a string or data or whatever)
        // https://www.macstories.net/linked/pythonista-3-2-syncs-scripts-with-icloud-supports-open-in-place-via-ios-11s-files-app/
    }
    
    override func didSelectCancel() {
        // This is called after the user selects Cancel - not on Post.
        // Usually there is nothing to be done.
        print("didSelectCancel")
    }

    override func didSelectPost() {
        // This is called after the user selects Post - not on Cancel.
        // Do the upload of contentText and/or NSExtensionContext attachments.
    
        print("didSelectPost")
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
