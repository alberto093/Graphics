






<img src="https://img.shields.io/cocoapods/v/Graphics.svg?label=version"> [![Platform](https://img.shields.io/cocoapods/p/Graphics.svg?style=flat)](https://developer.apple.com/iphone/index.action) <img src="https://img.shields.io/badge/supports-Swift%20Package%20Manager%2C%20CocoaPods%2C%20Carthage-green.svg">

  

  

## Welcome to Graphics!

  

******Graphics****** is an open source project that allows to create powerful graphics components.

  

If you'd like to contribute to Graphics see [******Contributing******](#contributing).

  

In this version you can use a lot of provided modifiers, create new ones and combine them together.

  

Provided modifiers allows to create components following ****neumorphism****, ****glassmorphism****, minimalism and any kind of UI design style.

  

You don't need to create complex views hierarchy, Graphics will take care of it.

The layer of meaning is: "One line of code for a view modifier to apply" as like as SwiftUI does.

  

- [Features](#features)

  

- [Requirements](#requirements)

  

- [Installation](#installation)

  

- [Usage](#usage)

  

- [Create a new modifier](#create-a-new-modifier)

  

- [Contributing](#contributing)

  

  

## Features

  

- [x] It is built on native UIKit layout system

  

- [x] Support any kind of UI design style

  

- [x] Allows to create custom modifiers (feel free to create a PR!)

  

- [x] Ready for support animations (work in progress)

  

## Requirements

  

- iOS 11.0+ (some APIs require iOS 13.0+)

  

- Xcode 11+

  

- Swift 5.1+

  

  

## Installation

  

  

### CocoaPods

  

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Graphics into your Xcode project using CocoaPods, specify it in your `Podfile`:

  

  

```ruby

  

pod 'Graphics'

  

```

  

  

### Carthage

  

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Graphics into your Xcode project using Carthage, specify it in your `Cartfile`:

  

  

```ogdl

  

github "alberto093/Graphics"

  

```

  

  

### Swift Package Manager

  

[Swift Package Manager](https://swift.org/package-manager/) is a dependency manager built into Xcode.

  

  

If you are using Xcode 11 or higher, go to ******File / Swift Packages / Add Package Dependency...****** and enter package repository URL ******https://github.com/alberto093/Graphics.git******, then follow the instructions.

  

Once you have your Swift package set up, adding ImageUI as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

  

  

```swift

  

dependencies: [

  

.package(url: "https://github.com/alberto093/Graphics.git")

  

]

  

```

  

  

## Usage

  

  

## Create a new modifier

  

## Contributing

  

[Graphics's roadmap](https://trello.com/b/U9h84E5f/graphics) is managed by Trello and is publicly available. If you'd like to contribute, please feel free to create a PR.

  

  

## License

  

ImageUI is released under the MIT license. See [LICENSE](https://github.com/alberto093/Graphics/blob/master/LICENSE) for details.
