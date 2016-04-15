# Subtitlr

Subtitlr is an open source OS X app used to find and download subtitles easily. Video files are dropped into the app which then finds their hashcodes using OpenSubtitles.org algorithm and maches them against their database. Matched subtitles are downloaded in the same directory where the video files are located.

## Installation


### Prerequisites
1. XCode (can be downloaded from the app store)
2. [CocoaPods](https://cocoapods.org)

### Installation Instructions
Clone the repository into a folder of your choice, and run `pod install` inside that folder. This will download the necessary dependencies and create a **Subtitlr.xcworkspace** file.

Open the **Subtitlr.xcworkspace** file in XCode, go to "Product->Build" in the top bar, once this has built right-click on the "Products" folder in the left hand sidebar, and click "Open in Finder". **Subtitlr.app** will be in there, you can then drag this into your Applications folder.

Alternatively, you can download Subtitlr.app in a ZIP file [here] (https://www.dropbox.com/s/et60e6lcvi3h2qc/Subtitlr.zip?dl=0). 
