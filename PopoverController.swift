//
//  PopoverController.swift
//  subs
//
//  Created by Lucija Frković on 27/07/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import Cocoa

class PopoverController: NSViewController {

    @IBOutlet weak var languageSelection: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        languageSelection.addItemsWithTitles((Language.getLanguages().allKeys as! [String]).sort())
        
        let userSubtitleLanguage = NSUserDefaults.standardUserDefaults().valueForKey(Constants.Keys.subtitleLanguage) as! String
        
        let subtitleDropdownTitle = Language.getLanguages().allKeysForObject(userSubtitleLanguage)[0] as! String
        
        
        languageSelection.selectItemWithTitle(subtitleDropdownTitle)

    }

    let languages = Language.getLanguages()
    
    @IBAction func changeLanguage(sender: NSPopUpButton) {
        
        let selectedItem = sender.titleOfSelectedItem!
        
        NSUserDefaults.standardUserDefaults().setValue(languages[selectedItem],  forKey: Constants.Keys.subtitleLanguage)
       
    }
}
