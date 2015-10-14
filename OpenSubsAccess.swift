//
//  OpenSubsAccess.swift
//  Subtitlr
//
//  Created by Lucija Frković on 19/08/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import Foundation


class OpenSubsAccess {
    
    var token: String?

    /**
        Used to communicate to OpenSubtitles.org
        Synchronised requests are made to OpenSubtitles via HTTPS connection, using
        XML-RPC protocol (Cocoa XML-RPC framework is used)
    
        Timeout set to 30sec
    */
    func talkToOpenSubs(method: String, params: [AnyObject]) -> NSDictionary? {
    
        let url = NSURL(string: Constants.OSconnectionString)
        let request = XMLRPCRequest(URL: url)
        
        request.setMethod(method, withParameters: params)
        request.setTimeoutInterval(NSTimeInterval(30)) //Timeout set to 30sec
        do {
            //fuck yeah!!!
            let response = try XMLRPCConnection.sendSynchronousXMLRPCRequest(request)
            return response.object() as? NSDictionary
            
        } catch {
            //print(error)
            //TODO: error handling!
            //maybe unnecessary?
        }
        
        return nil
    }
    
    /**
        Tries to log in to OpenSubtitles.org, returns
        token to be reused in a single session
    */
    func logIn() {
        let resultDict = talkToOpenSubs(Constants.OSMethods.logIn, params: ["", "", "eng", Constants.OSUserAgent])
        if resultDict != nil && resultDict!.valueForKey("token") != nil {
            token = resultDict!.valueForKey("token") as? String
        }
 
    }

    
    /**
        Creates the appropriate OpenSubtitles structure to get subtitle info for a particular video.
        Checks whether a required subtitle exists, returns its ID and format
    */
    
    func getSubtitle(hash: String, size: Double) -> (id: Int, format: String)? {
        if (token != nil) {
            var params = [AnyObject]()
            params.append(token!)
            
            var video = [String:AnyObject]()
            video["sublanguageid"] = NSUserDefaults.standardUserDefaults().valueForKey(Constants.Keys.subtitleLanguage) as! String
            video["moviehash"] = hash
            video["moviesize"] = size
            var videos = [AnyObject]()
            videos.append(video)
            
            params.append(videos)
            
            if let resultDict = talkToOpenSubs(Constants.OSMethods.searchSubtitles, params: params) as NSDictionary! {
                
                if let firstResult = (resultDict["data"] as? NSArray) {
                    if (firstResult.count > 0){
                        let firstSubId = firstResult[0]["IDSubtitleFile"] as! String
                        let subtitleFormat = firstResult[0]["SubFormat"] as! String
                        return (Int(firstSubId)!, subtitleFormat)
                    }
                }
                
            }
            
            
        }
        return nil
    }

    
    
    func downloadSub(subId: Int, format: String) -> NSData? {
        if token != nil {
            var params = [AnyObject]()
            params.append(token!)
            
            var subIds = [Int]()
            subIds.append(subId)
            params.append(subIds)
            
            let resultDict = talkToOpenSubs(Constants.OSMethods.downloadSubtitles, params: params) as NSDictionary!
           
            let subtitle = ((resultDict["data"] as! NSArray)[0] as! NSDictionary)["data"] as! String
            let subFile = NSData(base64EncodedString: subtitle, options: [])!.gunzippedData()
            
            return subFile
        }
        
        return nil
    }
}