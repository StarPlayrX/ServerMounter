//
//  AppDelegate.swift
//  ServerMounter
//
//  Created by Todd Bruss on 6/20/15
//  Copyright © 2016 SignUpGenius. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBAction func openWindow(sender: AnyObject) {
        myWindow.makeKeyAndOrderFront(self)

    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
            }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            
                    myWindow.makeKeyAndOrderFront(self)
         
        }
        
        return true
    }

}

