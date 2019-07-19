//
//  WindowController.swift
//  ServerMounter
//
//  Created by Todd Bruss on 6/20/15
//  Copyright © 2016 SignUpGenius. All rights reserved.
//

import Cocoa

var myWindow: NSWindow = NSWindow()

class WindowController: NSWindowController {
    override func windowDidLoad() {
        shouldCascadeWindows = false
        window?.setFrameAutosaveName("MainWindow")
        super.windowDidLoad()
        myWindow = window!  // name the window so we can call it later  (could not create an IB outlet for some reason)
        
    }
    
    
}

