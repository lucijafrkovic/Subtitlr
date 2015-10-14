//
//  Videos.swift
//  subs
//
//  Created by Lucija Frković on 21/07/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import Foundation



class Video {
    init(path: String){
        self.path = path
        self.subStatus = SubtitleStauts.NotSearched
    }
    
    var path: String
    
    enum SubtitleStauts {
        case NotSearched
        case Found
        case NotFound
    }
    
    var subStatus: SubtitleStauts?
  
    var subtitle: Subtitle?
    
    var hash: String {
        get {
            return FileHash().stringForHash(FileHash().hashForPath(path).fileHash) as String
        }
    }
    
    var size: UInt64 {
        get {
            return FileHash().hashForPath(path).fileSize
        }
    }
    
    
    var fileName: String {
        get {
            return (path as NSString).lastPathComponent
        }
    }
    
    func downloadSubtitle(){
        let osApi = OpenSubsAccess()
        osApi.logIn()
        
        if let result = osApi.getSubtitle(self.hash, size: Double(self.size)){
            let subFile = osApi.downloadSub(result.id, format: result.format)
            
            subtitle = Subtitle(path: path, ext: result.format)
            NSFileCoordinator.addFilePresenter(subtitle!)
            
            if let fData = subtitle, let url = fData.presentedItemURL {
                var errorMain: NSError?
                let coord = NSFileCoordinator(filePresenter: fData)
                coord.coordinateWritingItemAtURL(url, options: NSFileCoordinatorWritingOptions(), error: &errorMain, byAccessor: { writeUrl in
                    subFile!.writeToFile(self.subtitle!.path, atomically: true)
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(self.subtitle!.path) {
                        self.subStatus = SubtitleStauts.Found
                    }
                    return
                })
            }
        }
        else {
            subStatus = SubtitleStauts.NotFound
        }
        
    }
    
}
