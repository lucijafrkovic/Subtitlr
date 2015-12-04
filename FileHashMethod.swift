//
//  FileHashMethod.swift
//  OpenSubsProj
//
//  Created by Lucija Frković on 26/03/15.
//  Copyright (c) 2015 Lucija Frković. All rights reserved.
//  Based on Objective-C hash implementation for Mac by subsmarine.com

import Foundation

class FileHash {

    struct VideoHash {
        var fileHash: UInt64;
        var fileSize: UInt64;
        init() {
            fileHash = 0;
            fileSize = 0;
        }
    }

    func stringForHash(hash: UInt64) -> NSString {
        return NSString(format: "%qx", hash)
    }


    func hashForPath(path: NSString) -> VideoHash {
        var hash = VideoHash();
        
        let readFile:NSFileHandle? =  NSFileHandle(forReadingAtPath: path as String);
        hash = hashForFile(readFile!);
        return hash;
    }

    func hashForUrl(url: NSURL) -> VideoHash {
        var hash = VideoHash();
        let error =  NSErrorPointer();
        
        var readFile: NSFileHandle?
        do {
            readFile = try NSFileHandle(forReadingFromURL: url)
        } catch let error1 as NSError {
            error.memory = error1
            readFile = nil
        };
        hash = hashForFile(readFile!);
        return hash;
    }

    func hashForFile(handle: NSFileHandle) -> VideoHash {
        var returnHash =  VideoHash();
        
        let CHUNK_SIZE:UInt64 = 65536;
        var fileDataBegin, fileDataEnd:NSData;
        var hash:UInt64 = 0;
        
        fileDataBegin = handle.readDataOfLength(Int(CHUNK_SIZE));
        handle.seekToEndOfFile();
        
        let fileSize = handle.offsetInFile;
        if (fileSize < CHUNK_SIZE) {
            return returnHash;
        }
        
        handle.seekToFileOffset(max(0, (fileSize - CHUNK_SIZE)));
        fileDataEnd = handle.readDataOfLength(Int(CHUNK_SIZE));
        
        var data_bytes = UnsafeBufferPointer<UInt64>(
            start: UnsafePointer(fileDataBegin.bytes),
            count: Int(CHUNK_SIZE)/sizeof(UInt64)
        )

        hash = data_bytes.reduce(hash) { $0 &+ $1 }
      
        data_bytes = UnsafeBufferPointer<UInt64>(
            start: UnsafePointer(fileDataEnd.bytes),
            count: Int(CHUNK_SIZE)/sizeof(UInt64)
        )
        
        hash = data_bytes.reduce(hash) { $0 &+ $1 }
        
        hash = hash &+ fileSize
        
        returnHash.fileHash = hash;
        returnHash.fileSize = fileSize;
        
        return returnHash;
        
    }
}
