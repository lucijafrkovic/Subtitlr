//
//  MainWindowController.swift
//  Subtitlr
//
//  Created by Lucija Frković on 11/10/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var dropzone: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableContainer: NSView!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var dropzoneImage: NSImageView!
    
    let popover = NSPopover()
    
    var showDropzone = true
    
    var videos = [Video]()
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.registerForDraggedTypes([NSFilenamesPboardType])
        
        //color the container view white, so the dropzone gets white as well
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        //unregister NSImageView in dropzone view from receiving dragging operation
        //otherwise it interferes with dragging files to the whole dropzone area
        dropzoneImage.unregisterDraggedTypes()
        
        tableView.setDelegate(self)
        
        //bind popover to its controller
        popover.contentViewController = PopoverController()
        popover.behavior = NSPopoverBehavior.Transient
        
    }
    
    
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            if let filePaths = board as? [String] {
                
                //geting the path of dropped file
                for path in filePaths {
                    //only videos are allowed
                    if Constants.fileTypes.contains((path as NSString).pathExtension.lowercaseString){
                        videos.append(Video(path: path))
                    }
                }
                
                if videos.count > 0 {
                    checkAndSwitchToTableView()
                    
                    tableView.reloadData()
                }
                
                return true
            }
        }
        return false
    }
    
    //Switches to table view if dropzone is active
    func checkAndSwitchToTableView() {
        if showDropzone {
            showDropzone = false
            //remove dropzone and show table with files
            containerView.animator().replaceSubview(dropzone, with: tableContainer)
            tableContainer!.hidden = false
        }
    }
    
    func concludeDragOperation(sender: NSDraggingInfo) {
        getSubtitlesForDroppedFiles()
    }
    
    //counters to help with displaying proper notification info
    var videoFoundCount = 0
    var videoNotFoundCount = 0
    var videoNotSearchedCount = 0
    
    func getSubtitlesForDroppedFiles(){
        for (index, video) in videos.enumerate() {
            if video.subStatus == Video.SubtitleStauts.NotSearched {
                videoNotSearchedCount += 1
                
                // Subtitle search and download is done in a separate thread on a lower priority than
                // table reload. Otherwise, the application visually gets "stuck" until all subs are downloaded
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    video.downloadSubtitle()
                    
                    dispatch_async(dispatch_get_main_queue()){
                        if video.subStatus == Video.SubtitleStauts.Found {
                            self.videoFoundCount += 1
                        }
                        else if video.subStatus == Video.SubtitleStauts.NotFound {
                            self.videoNotFoundCount += 1
                        }
                        
                        //refresh only the first (status) and third(finder icon/link to manual search) columns 
                        //of the table
                        let columns = NSMutableIndexSet()
                        columns.addIndex(0)
                        columns.addIndex(2)
                        self.tableView.reloadDataForRowIndexes(NSIndexSet(index: index), columnIndexes: columns)
                        
                        //if all videos are searched for, display notification
                        if ((self.videoFoundCount + self.videoNotFoundCount) == self.videoNotSearchedCount){
                            self.notifyUser()
                            self.resetSearchResultCounters()
                            
                        }
                        
                    }
                })
            }
        }
        
    }
    
    func resetSearchResultCounters(){
        videoNotSearchedCount = 0
        videoNotFoundCount = 0
        videoFoundCount = 0
    }
    
    func notifyUser(){
        let notify = NSUserNotification()
        notify.title = "Finished searching for subtitles"
        notify.subtitle = "Subtitles found for \(videoFoundCount) of \(videoNotSearchedCount) videos"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notify)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return videos.count
    }
    
    //prevents row selection
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        return NSIndexSet();
    }
    
    
    //Resolve table column values
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //middle column showing video path, middle of text is truncated to fit the cell
        if tableColumn?.identifier == "fileName" {
            var fileName: NSTextField? = tableView.makeViewWithIdentifier("fileName", owner: self) as? NSTextField
            
            if fileName == nil {
                fileName = NSTextField(frame: NSRect())
                fileName!.identifier = "fileName"
                fileName?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
            }
            fileName?.stringValue = videos[row].fileName
            fileName?.bezeled = false
            fileName?.bordered = false
            fileName?.selectable = false
            fileName?.backgroundColor = NSColor.clearColor()
            return fileName
        }
        else if tableColumn?.identifier == "findSubtitle" {
            var findSubtitle: NSButton? = tableView.makeViewWithIdentifier("finder", owner: self) as? NSButton
            
            if findSubtitle == nil {
                findSubtitle = NSButton(frame: NSRect())
                findSubtitle!.identifier = "findSubtitle"
            }
            
            
            findSubtitle?.bordered = false
            
            findSubtitle?.setButtonType(NSButtonType.MomentaryChangeButton)
            findSubtitle?.bezelStyle = NSBezelStyle.RoundedDisclosureBezelStyle
            findSubtitle?.imagePosition = NSCellImagePosition.ImageOnly
            findSubtitle?.target = self
            
            findSubtitle?.tag = row
            
            if videos[row].subStatus == Video.SubtitleStauts.Found {
                findSubtitle?.image = NSImage(named: NSImageNameRevealFreestandingTemplate)
                findSubtitle?.toolTip = "Show subtitle in Finder"
                findSubtitle?.action = "revealInFinder:"
                
                return findSubtitle
            }
                //show direct search by filename on opensubtitles
            else if videos[row].subStatus == Video.SubtitleStauts.NotFound {
                
                findSubtitle?.image = NSImage(named: NSImageNameShareTemplate)
                findSubtitle?.bordered = false
                findSubtitle?.toolTip = "Search in browser on OpenSubtitles.org"
                findSubtitle?.action = "searchOpenSubs:"
                
                return findSubtitle
            }
            
            
        }
        else if tableColumn?.identifier == "status" {
            if (videos[row].subStatus == Video.SubtitleStauts.NotSearched) {
                var spinner: NSProgressIndicator? = tableView.makeViewWithIdentifier("status", owner: self) as? NSProgressIndicator
                
                if spinner == nil {
                    spinner = NSProgressIndicator(frame: NSRect())
                    spinner!.identifier = "status"
                }
                spinner?.style = NSProgressIndicatorStyle.SpinningStyle
                spinner?.controlSize = NSControlSize.SmallControlSize
                spinner?.startAnimation(nil)
                spinner?.bezeled = false
                
                spinner?.toolTip = "Searching subtitles..."
                
                return spinner
            }
            else  {
                var status: NSTextField? = tableView.makeViewWithIdentifier("status", owner: self) as? NSTextField
                
                if status == nil {
                    status = NSTextField(frame: NSRect())
                    status!.identifier = "status"
                }
                status?.stringValue = videos[row].subStatus == Video.SubtitleStauts.Found ? "✓" : "x"
                status?.font = videos[row].subStatus == Video.SubtitleStauts.Found ? NSFont(name: "Devanagari MT", size: 12): NSFont(name: "Zapf Dingbats", size: 12)
                status?.alignment = NSTextAlignment.Center
                status?.bezeled = false
                status?.bordered = false
                status?.selectable = false
                status?.backgroundColor = NSColor.clearColor()
                status?.toolTip = videos[row].subStatus == Video.SubtitleStauts.Found ? "Subtitle was found and downloaded to video location.": "Subtitle was not found."
                
                
                return status
            }
            
        }
        
        return nil
    }
    
    /*  Show subtitle in finder.
    Finder icon is assigned a tag value corresponding to matching file's array index
    */
    func revealInFinder(sender: NSButton){
        let url = NSURL.fileURLWithPath(videos[sender.tag].subtitle!.path)
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([url])
    }
    
    func searchOpenSubs(sender: NSButton){
        let lang = NSUserDefaults.standardUserDefaults().valueForKey(Constants.Keys.subtitleLanguage) as! String
        let urlString = "http://www.opensubtitles.org/en/search2/sublanguageid-\(lang)/moviename-\(videos[sender.tag].fileName)"
        let safeUrl = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: safeUrl)
        NSWorkspace.sharedWorkspace().openURL(url!)
    }
    
    //opens or closes settings popover
    @IBAction func togglePopover(sender: NSButton) {
        if popover.shown {
            popover.close()
        }
        else {
            popover.showRelativeToRect( sender.bounds, ofView: sender, preferredEdge: NSRectEdge(rawValue: 3)!)
        }
    }
    
    @IBAction func selectVideoFilesFromFinder(sender: NSButton) {
        sender.enabled = false
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = Constants.fileTypes
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsConcurrentViewDrawing = false
        
        openPanel.beginWithCompletionHandler{result -> Void in
            if result == NSFileHandlingPanelOKButton {
                for file in openPanel.URLs {
                    self.videos.append(Video(path: file.path!))
                    self.checkAndSwitchToTableView()
                }
                self.tableView.reloadData()
                self.getSubtitlesForDroppedFiles()
            }
            sender.enabled = true
        }
    }
    
}
