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
    let userDefaults = UserDefaults.standard

    @IBAction func openWindow(_ sender: AnyObject) {
        myWindow.makeKeyAndOrderFront(self)

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
            }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            
                    myWindow.makeKeyAndOrderFront(self)
         
        }
        
        return true
    }

}

