# NimbusMobileFuseKit

A Nimbus SDK extension for **MobileFuse bidding and rendering**. It enriches Nimbus ad requests with MobileFuse demand and handles ad rendering through the MobileFuse SDK when it wins the auction.

## Versioning

NimbusMobileFuseKit **major versions are kept in sync** with the MobileFuse SDK. For example, NimbusMobileFuseKit `1.x.x` depends on MobileFuse SDK `1.x.x`.
 
Minor and patch versions are independent — a NimbusMobileFuseKit patch release does not necessarily correspond to a MobileFuse SDK patch release, and vice versa.
 
| NimbusMobileFuseKit | MobileFuse SDK |
|---|---|
| 1.x.x | 1.x.x |

## Installation

### Swift Package Manager

#### Xcode Project

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/adsbynimbus/nimbus-ios-mobilefuse
   ```
3. Set the dependency rule to **Up to Next Major Version** and enter `1.0.0` as the minimum.
4. Click **Add Package** and select the **NimbusMobileFuseKit** library when prompted.

#### Package.swift

If you're managing dependencies through a `Package.swift` file, add the following:

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-mobilefuse", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusMobileFuseKit", package: "nimbus-ios-mobilefuse")
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'NimbusMobileFuseKit'
```

Then run:

```sh
pod install
```

## Usage
 
Navigate to where you call `Nimbus.initialize` and register the `MobileFuseExtension`:
 
```swift
import NimbusMobileFuseKit
 
Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    MobileFuseExtension()
}
```

Nimbus will automatically initialize the MobileFuse SDK.

That's it — MobileFuse is now enabled in all upcoming requests.

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs/sdk/ios) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.

## Sample App

See NimbusMobileFuseKit in action in our public [sample app repository](https://github.com/adsbynimbus/nimbus-ios-sample), which demonstrates end-to-end integration including setup, bid requests, and ad rendering.
