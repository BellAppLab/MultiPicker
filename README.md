# MultiPicker

An Image Picker View Controller for iOS that supports multiple images, multiple presentation styles, storyboards and rotation.

_v0.5.0_

## Usage



## Requirements

* iOS 8.0+
* Swift 3.0

## Installation

### Cocoapods

Because of [this](http://stackoverflow.com/questions/39637123/cocoapods-app-xcworkspace-does-not-exists), I've dropped support for Cocoapods on this repo. I cannot have production code rely on a dependency manager that breaks this badly. 

### Git Submodules

**Why submodules, you ask?**

Following [this thread](http://stackoverflow.com/questions/31080284/adding-several-pods-increases-ios-app-launch-time-by-10-seconds#31573908) and other similar to it, and given that Cocoapods only works with Swift by adding the use_frameworks! directive, there's a strong case for not bloating the app up with too many frameworks. Although git submodules are a bit trickier to work with, the burden of adding dependencies should weigh on the developer, not on the user. :wink:

To install MultiPicker using git submodules:

```
cd toYourProjectsFolder
git submodule add -b submodule --name MultiPicker https://github.com/BellAppLab/MultiPicker.git
```

Navigate to the new MultiPicker folder and drag the Pods folder to your Xcode project.

## Author

Bell App Lab, apps@bellapplab.com

## License

MultiPicker is available under the MIT license. See the LICENSE file for more info.
