//
//  Subtitle.swift
//  subs
//
//  Created by Lucija Frković on 18/09/15.
//  Copyright (c) 2015 Lucija Frković. All rights reserved.
//

import Foundation


class Subtitle: NSObject {
    var path: String
    var ext: String
    var videoPath: String
    
    init(path: String, ext: String){
        self.videoPath = path
        self.path = (path as NSString).stringByDeletingPathExtension + "." + ext
        self.ext = ext
    }
}

extension Subtitle: NSFilePresenter {
    
    /*
        Output subtitle file
    */
    var presentedItemURL: NSURL? {
        let filePath = (path as NSString).stringByDeletingPathExtension + "." + ext
        return NSURL(fileURLWithPath: filePath)
    }
    
    /*
        "Source" file - video file which will get "modified and saved" as subtitle file
    */
    var primaryPresentedItemURL: NSURL? {
        return NSURL(fileURLWithPath: videoPath)
    }
    
    var presentedItemOperationQueue: NSOperationQueue {
        return NSOperationQueue.mainQueue()
    }
}