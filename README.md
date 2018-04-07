# swift-localstorage

![Swift](https://img.shields.io/badge/swift-4.1-brightgreen.svg)
![Xcode](https://img.shields.io/badge/xcode-9.3-brightgreen.svg)
![License](https://img.shields.io/badge/license-GPL-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/eberl_se)

Making Apple's stock **Files** app work locally.

## Product page

For more information, please visit [localstorage.eberl.se](https://localstorage.eberl.se/).

Or view *Local Storage* on the [App Store](https://itunes.apple.com/app/id1339306324).

## Contributing & Questions

Bugs should be reported [here on GitHub](https://github.com/geberl/swift-localstorage/issues). 

If you have any questions or an idea for a new feature, please send your suggestions to my Twitter account [@eberl_se](https://twitter.com/eberl_se).

## Building

- Checkout the repo
- `cd ~/Development/swift-localstorage/LocalStorage/`
- `pod install`
- Open **Xcode** using `localstorage.xcworkspace`
- Adjust signing settings for each target
- Build & run

## Updating CocoaPods

- `cd ~/Development/swift-localstorage/LocalStorage/`
- Edit the `Podfile` (remove all fixed version numbers)
- `pod install`
- Open **Xcode** using `localstorage.xcworkspace`
- Try to build & run, check for new warnings & errors, check functionality
- Edit the `Podfile` (add the fixed version numbers that are confirmed working now)
- Commit

## Attributions

- Local Storage uses the following **CocoaPods**:
    - [Charts](https://cocoapods.org/pods/Charts) by *Daniel Cohen Gindi* and *Philipp Jahoda* ([on GitHub](https://github.com/danielgindi/Charts))
    - [SWCompression](https://cocoapods.org/pods/SWCompression) by *Timofey Solomko* ([on GitHub](https://github.com/tsolomko/SWCompression))
    - [YMTreeMap](https://cocoapods.org/pods/YMTreeMap) by *Adam Kaplan* ([on GitHub](https://github.com/yahoo/YMTreeMap))
    - [CommonCryptoModule](https://cocoapods.org/pods/CommonCryptoModule) by *Nikita Kukushkin* ([on GitHub](https://github.com/nkukushkin/CommonCryptoModule))
- Thanks to everyone who submitted a bug!
