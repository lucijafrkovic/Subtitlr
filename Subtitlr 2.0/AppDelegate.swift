//
//  AppDelegate.swift
//  subs
//
//  Created by Lucija Frković on 21/07/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindowController: MainWindowController?
    var popoverController: PopoverController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let mainWindowController = MainWindowController()
        let popoverController = PopoverController()
        
        //put the window of the window controller on screen
        mainWindowController.showWindow(self)
        self.mainWindowController = mainWindowController
        self.popoverController = popoverController
        
        //check if user has selected a language, if not, set to English
        if NSUserDefaults.standardUserDefaults().objectForKey(Constants.Keys.subtitleLanguage) == nil {
            NSUserDefaults.standardUserDefaults().setObject(Constants.defaultSubtitleLanguage, forKey: Constants.Keys.subtitleLanguage)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        
        //save user settings before quitting
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}

