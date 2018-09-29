# swift-localstorage

![Swift](https://img.shields.io/badge/swift-4.2-brightgreen.svg)
![Xcode](https://img.shields.io/badge/xcode-10.0-brightgreen.svg)
![License](https://img.shields.io/badge/license-GPL-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

*A place to store your files.*

## Product pages

For more information, please visit [localstorage.eberl.se](https://localstorage.eberl.se/).

Or view *Local Storage* on the [App Store](https://itunes.apple.com/app/id1339306324).

## Contributing & Questions

All **bugs** should be reported [here on GitHub](https://github.com/geberl/swift-localstorage/issues).

If you have **questions** or **ideas** for new features, please send me your suggestions via email [localstorage@eberl.se](mailto:localstorage@eberl.se).

## Localization

I need some help for translating *Local Storage* into languages other than German and English.

The strings in some text files need to be edited. Should only take 30 minutes and there's no programming involved.

- `Local Storage/de/main/de.lproj/Localizable.strings`
- `Local Storage/Main/de.lproj/Main.strings`
- `Local Storage/Settings/de.lproj/Settings.strings`
- `Extract/de.lproj/Localizable.strings`
- `Hash/de/de.lproj/Localizable.strings`
- `Hash/de.lproj/MainInterface.strings`

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
- Try to build & run, check for new warnings & errors, verify that everything is working
- Edit the `Podfile` (add the fixed version numbers that are confirmed working now)
- Commit

## Attributions

- Local Storage uses the following **CocoaPods**:
    - [Charts](https://cocoapods.org/pods/Charts) by *Daniel Cohen Gindi* and *Philipp Jahoda* ([on GitHub](https://github.com/danielgindi/Charts))
    - [SWCompression](https://cocoapods.org/pods/SWCompression) by *Timofey Solomko* ([on GitHub](https://github.com/tsolomko/SWCompression))
    - [YMTreeMap](https://cocoapods.org/pods/YMTreeMap) by *Adam Kaplan* ([on GitHub](https://github.com/yahoo/YMTreeMap))
    - [CommonCryptoModule](https://cocoapods.org/pods/CommonCryptoModule) by *Nikita Kukushkin* ([on GitHub](https://github.com/nkukushkin/CommonCryptoModule))
- Localization:
    - *German* and *English* by Günther Eberl
- Contributors:
    - [femilamptey](https://github.com/femilamptey)
- Thanks to everyone who submitted a bug!
