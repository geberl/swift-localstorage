# Finding an app's bundle identifier of any app

Find the app you are looking for on the Apple AppStore.
For this example, we’ll use Yelp: https://itunes.apple.com/us/app/yelp/id284910350?mt=8

Copy the app ID number.
It’s just the numbers after the text “id” and before the “?”.
So in this case, it is: **284910350**.

Paste that ID number into this URL: https://itunes.apple.com/lookup?id=284910350

This will download a file `1.txt`

Search the output you get back for “bundleId”.
The app’s bundle ID will be listed there: `com.yelp.yelpiphone`

# For Files

https://itunes.apple.com/us/app/files/id1232058109?mt=8

ID: **1232058109**

Lookup URL: https://itunes.apple.com/lookup?id=1232058109

Bundle ID: `com.apple.DocumentsApp`

Nothing about URL Schemes in there ...


{
    "resultCount": 1,
        "results": [
            {
                "artistViewUrl": "https://itunes.apple.com/us/developer/apple/id284417353?mt=12&uo=4", "artworkUrl60": "http://is4.mzstatic.com/image/thumb/Purple128/v4/eb/ce/4a/ebce4a36-15ee-e89d-7ae3-937a64148669/source/60x60bb.jpg", "artworkUrl100": "http://is4.mzstatic.com/image/thumb/Purple128/v4/eb/ce/4a/ebce4a36-15ee-e89d-7ae3-937a64148669/source/100x100bb.jpg", "ipadScreenshotUrls": ["http://is5.mzstatic.com/image/thumb/Purple128/v4/ba/d8/65/bad8656c-bca6-44a1-7ce6-3e7f5fb64258/source/552x414bb.jpg"], "appletvScreenshotUrls": [], "artworkUrl512": "http://is4.mzstatic.com/image/thumb/Purple128/v4/eb/ce/4a/ebce4a36-15ee-e89d-7ae3-937a64148669/source/512x512bb.jpg", "kind": "software", "features": ["iosUniversal"],
                "supportedDevices": ["iPhone5s-iPhone5s", "iPadAir-iPadAir", "iPadAirCellular-iPadAirCellular", "iPadMiniRetina-iPadMiniRetina", "iPadMiniRetinaCellular-iPadMiniRetinaCellular", "iPhone6-iPhone6", "iPhone6Plus-iPhone6Plus", "iPadAir2-iPadAir2", "iPadAir2Cellular-iPadAir2Cellular", "iPadMini3-iPadMini3", "iPadMini3Cellular-iPadMini3Cellular", "iPodTouchSixthGen-iPodTouchSixthGen", "iPhone6s-iPhone6s", "iPhone6sPlus-iPhone6sPlus", "iPadMini4-iPadMini4", "iPadMini4Cellular-iPadMini4Cellular", "iPadPro-iPadPro", "iPadProCellular-iPadProCellular", "iPadPro97-iPadPro97", "iPadPro97Cellular-iPadPro97Cellular", "iPhoneSE-iPhoneSE", "iPhone7-iPhone7", "iPhone7Plus-iPhone7Plus", "iPad611-iPad611", "iPad612-iPad612", "iPad71-iPad71", "iPad72-iPad72", "iPad73-iPad73", "iPad74-iPad74", "iPhone8-iPhone8", "iPhone8Plus-iPhone8Plus", "iPhoneX-iPhoneX"],
                "screenshotUrls": ["http://is3.mzstatic.com/image/thumb/Purple118/v4/a2/b7/29/a2b729e1-7e8d-2a24-4db9-d44e12a09760/source/392x696bb.jpg", "http://is5.mzstatic.com/image/thumb/Purple128/v4/15/00/65/15006523-02f4-b5c7-af69-71db6a8acfd4/source/392x696bb.jpg", "http://is3.mzstatic.com/image/thumb/Purple128/v4/89/2b/88/892b8865-2dcb-64e1-52fb-c36f1a0ac3cc/source/392x696bb.jpg"], "advisories": [], "isGameCenterEnabled": false, "trackCensoredName": "Files", "trackViewUrl": "https://itunes.apple.com/us/app/files/id1232058109?mt=8&uo=4", "contentAdvisoryRating": "4+", "fileSizeBytes": "581632",
                "languageCodesISO2A": ["AR", "CA", "HR", "CS", "DA", "NL", "EN", "FI", "FR", "DE", "EL", "HE", "HI", "HU", "ID", "IT", "JA", "KO", "MS", "NB", "PL", "PT", "RO", "RU", "ZH", "SK", "ES", "SV", "TH", "ZH", "TR", "UK", "VI"], "trackContentRating": "4+", "minimumOsVersion": "11.0", "sellerName": "Apple Inc.", "genreIds": ["6002"], "wrapperType": "software", "version": "1.2.1", "currency": "USD", "artistId": 284417353, "artistName": "Apple", "genres": ["Utilities"], "price": 0.00,
                "description": "Access and organize your files no matter where they’re located — on your device or in the cloud with Files. The Recents view displays all the files you’ve been working on lately in high-resolution thumbnails. Use the powerful Browse view to navigate folders, organize your files with tags, move files between folders, and search. Files also makes it easy to access iCloud Drive and third-party cloud storage services such as Dropbox and Box.\n\nFeatures\n\n• Press the Files icon on the Dock or Home screen to quickly open a file from anywhere in iOS.\n\n• Use tags to organize files stored with different cloud providers and across different apps.\n\n• Pin your favorite folders to the sidebar in Browse view for quick access to the folders you use most.\n\n• Give people access to any file stored in iCloud Drive by sharing a link from the Files app. \n\n• Drag and drop to select files and organize them into folders.", "trackId": 1232058109, "trackName": "Files", "bundleId": "com.apple.DocumentsApp", "isVppDeviceBasedLicensingEnabled": true, "primaryGenreName": "Utilities", "currentVersionReleaseDate": "2017-09-15T22:41:04Z", "releaseDate": "2017-05-18T13:05:47Z", "formattedPrice": "Free", "primaryGenreId": 6002, "releaseNotes": "Bug fixes"
            }]
}
