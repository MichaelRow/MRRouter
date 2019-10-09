# URLRouter

![Swift](https://img.shields.io/badge/Swift-5.1-orange.svg) ![Version](https://img.shields.io/cocoapods/v/URLRouter.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![License](https://img.shields.io/cocoapods/l/URLRouter.svg?style=flat) ![Platform](https://img.shields.io/cocoapods/p/URLRouter.svg?style=flat)

## How to Use

#### For a NavigationController-base app

1. Set the routing object for the router.

   ```swi
   // get your root navigation controller here
   guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
   
   let naviNavigator = NavigationControllerNavigator(navi)
   let router = Router(naviNavigator)
   ```
   
2. Register view controllers.

   ```swi
   // You can get the routing parameters if your VCs conform to RoutableViewController protocol.
   // The VC stack management take no effects if you don't implemente the protocol.
   class GeneralVC: UIViewController, RoutableViewController {
       static var stackLevel: StackLevel { return .lowest }
       var parameters: [String : Any]
       required init(_ parameters: [String : Any]) {
           super.init(nibName: nil, bundle: nil)
       }
   }
   
   class UserVC: UIViewController, RoutableViewController {
       static var stackLevel: StackLevel { return .low }
       var parameters: [String : Any]
       required init(_ parameters: [String : Any]) {
           super.init(nibName: nil, bundle: nil)
       }
   }
   
   // Not conforming to the protocol is OK as also.
   class SettingsVC: UIViewController {}
   
   router.register(pattern: "router://general", viewControllerType: GeneralVC.self)
   router.register(pattern: "router://settings", viewControllerType: SettingsVC.self)
   
   // use <NAME> in the URL path components match all possible values, and you can get it as a parameter from the parameters dictionary.
   router.register(pattern: "router://user/<name>", viewControllerType: UserVC.self)
   ```

3. Open the URL registered. All the annorying measures will be perfectly managed by the navigator, just open it.

   ```swif
   // open use push by default
   router.open(url: "router://general")
   
   // or use push directly
   router.push(url: "router://settings", parameters: ["WiFi":true], option: [.withoutAnimation]) { error in
       if error == nil {
           print("Navigation Complete!")
       }
   }
   
   // you can present and wrap the VC in a navigation controller by adding the option
   router.present(url: "router://user/MichaelRow", option: [.wrapInNavigation])
   ```

#### For a TabBarController-base app

Just change the navigator type. 

```swif
guard let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else { return }

let tabBarNavigator = TabBarControllerNavigator(tabBarVC)
let router = Router(tabBarNavigator)
```

By the way, you can push your VC on any tab.

```sw
router.push(url: "router://general", tabbarIndex: 2)
```



## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0+ and Xcode 11.0+ are required.

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like URLRouter in your projects. See the ["Getting Started" guide for more information](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking). You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate URLRouter into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/MichaelRow/PodSpecs.git'
platform :ios, '8.0'

target 'YourTargetName' do
pod 'URLRouter'
end
```

Then, run the following command:

```bash
$ pod install
```

## Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate URLRouter into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "MichaelRow/URLRouter"
```

Run `carthage` to build the framework and drag the built `URLRouter.framework` into your Xcode project.

## License

URLRouter is available under the MIT license. See the LICENSE file for more info.
