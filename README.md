# Portfolio Sample iOS App: Virtual Tourist

Users specify travel locations around the world, and create virtual photo albums for each location. 
- Pictures are downloaded from Flickr.
- The locations and photo albums are stored using [Multithreaded Core Data](Reusable/CoreData/Stack/CoreDataManager.swift).
- Uses [Carthage](https://github.com/Carthage/Carthage) in place of CocoaPods as the package manager.
- Uses Alamofire & SwiftyJSON.
- Demos the use of asynchronous Operation (previously NSOperation) & Dispatch Queues.
- Adaptive layout. Any orientation at any size.
- Works on any device running iOS 10.


## Requirements

- Built with Swift 3.3 and Xcode 9.3.1.
- Carthage
- Not required but design assets managed by PaintCode.


## How to build
- Open the .xcodeproj file

### For simulator
- Build

### For device
- Open the project settings by clicking on the Project in the Project Navigator on the left side.
- Select the "VirtualTourist" target.
- In General (tab) -> Identity (section) change the bundle identifier to your own bundle identifier.
- Build


