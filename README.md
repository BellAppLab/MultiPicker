# MultiPicker

[![CI Status](http://img.shields.io/travis/Bell App Lab/MultiPicker.svg?style=flat)](https://travis-ci.org/Bell App Lab/MultiPicker)
[![Version](https://img.shields.io/cocoapods/v/MultiPicker.svg?style=flat)](http://cocoapods.org/pods/MultiPicker)
[![License](https://img.shields.io/cocoapods/l/MultiPicker.svg?style=flat)](http://cocoapods.org/pods/MultiPicker)
[![Platform](https://img.shields.io/cocoapods/p/MultiPicker.svg?style=flat)](http://cocoapods.org/pods/MultiPicker)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0+

## Installation

### CocoaPods

MultiPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MultiPicker"
```

### Git Submodules

**Why submodules, you ask?**

Following [this thread](http://stackoverflow.com/questions/31080284/adding-several-pods-increases-ios-app-launch-time-by-10-seconds#31573908) and other similar to it, and given that Cocoapods only works with Swift by adding the use_frameworks! directive, there's a strong case for not bloating the app up with too many frameworks. Although git submodules are a bit trickier to work with, the burden of adding dependencies should weigh on the developer, not on the user. :wink:

To install MultiPicker using git submodules:

```
cd toYourProjectsFolder
git submodule add -b Submodule --name MultiPicker https://github.com/BellAppLab/MultiPicker.git
```

Navigate to the new MultiPicker folder and drag the Pods folder to your Xcode project.

## Author

Bell App Lab, apps@bellapplab.com

## License

MultiPicker is available under the MIT license. See the LICENSE file for more info.
