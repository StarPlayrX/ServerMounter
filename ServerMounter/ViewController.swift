//
//  ViewController.swift
//  ServerMounter
//
//  Created by Todd Bruss on 6/20/15
//  Copyright © 2016 SignUpGenius. All rights reserved.
//

import Cocoa
import NetFS
import Foundation


class ViewController: NSViewController {

    let myProtocol = "afp://"
    let myServer = "10.0.10.4"
    let shareName = "Dropbox (SignUpGenius)"
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var Password: NSSecureTextField!
    @IBOutlet weak var changePassword: NSButton!
    @IBOutlet weak var myStatus: NSTextField!
    
    @IBAction func serverDisconnect(_ sender: AnyObject) {
       runEjectDisk(shareName)
    }
    
    @IBAction func serverConnect(_ sender: AnyObject) {
        let myUserName = userName.stringValue
        let myPassword = Password.stringValue
        let shouldChangePassword = changePassword.state
        
        userDefaults.setValue(myUserName, forKey: "userName")
        userDefaults.setValue(myPassword, forKey: "Password")
        userDefaults.setValue(changePassword.stringValue, forKey: "changePassword")
        
        if shouldChangePassword == 1 {
            //change password is only available via afp protocol
            let myURL = "afp://" + myServer + "/" + shareName
            asyncMountShare(myURL, shareName: shareName, userName: myUserName, password: "temp", shouldChangePassword: shouldChangePassword)
           // myStatus.stringValue = "In the popup window, click the 'Change Password' button on the lower left corner."
        } else {
            let myURL = myProtocol + myServer + "/" + shareName
            asyncMountShare(myURL, shareName: shareName, userName: myUserName, password: myPassword, shouldChangePassword: shouldChangePassword)
           // myStatus.stringValue = "Connecting..."
        }
        
    }
    
    func runEjectDisk(_ shareName: String) {
        let mountPointError = checkMountPointIntegity(shareName)
        
        if mountPointError == -1 {
            myStatus.stringValue = "It looks like you are already connected to the Server and have some files open. Please quit each App and save them. Thank you!"
        }
        
        if mountPointError != 0 && mountPointError != -1 {
            myStatus.stringValue = "Mmmmm.. we reached an unknown mount point error: \(mountPointError)... Please Hipchat this your network admin. Thank you."
        }
        
        if mountPointError == 0 {
            myStatus.stringValue = "Server share '\(shareName)' has been successfully disconnected."
        }
    
        //Run an Applescript to remove the Mount Point (aka Disk) if it still exists in the Finder
        /*
        let myAppleScript = "tell application \"Finder\"\nif disk \"" + shareName + "\" exists then\neject disk \"" + shareName + "\"\nend if\nend tell\n"
        NSLog(myAppleScript)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                NSAppleScript(source: myAppleScript)?.executeAndReturnError(nil)
        }
    
        This takes too long and does not always tell the user what's up. It will add more confusion */
    }

    
    func runAppleScript(_ shareName: String) {
        //Run an Applescript and show the Mount Point (aka Disk) in the Finder
        let myAppleScript = "repeat 20 times\ntell application \"Finder\"\nif disk \"" + shareName + "\" exists then\nactivate\nopen disk \"" + shareName + "\"\nexit repeat\nend if\ndelay 0.01\nend tell\nend repeat\n"
        //print(myAppleScript)
        
        DispatchQueue.main.async { () -> Void in
            NSAppleScript(source: myAppleScript)?.executeAndReturnError(nil)
        }
    }
    

    func myTest(_ myStat:Int32,  requestID:AsyncRequestID,  myMount:CFArray?, shareName:String) {
        if myStat == 0 {
            let myMountPoints = (myMount as! Array<Any>)
            myStatus.stringValue = "Success! Server access granted.\n\n" +  String(describing: myMountPoints[0])
            runAppleScript(shareName)
        }
        if myStat == -128
         {
            if userName.stringValue != "" {
                myStatus.stringValue = userName.stringValue + " cancelled."
            } else {
                myStatus.stringValue = "User cancelled."

            }
        }
        
        if myStat == 65 || myStat == 64 {
            myStatus.stringValue = "Either I need my eyes checked or I can't find the server. Please make sure you are on our Office Network. If you are out of the office, please use Dropbox.com, Thank you!"
        }
        
        if myStat == -5045 {
            myStatus.stringValue = "Password needs to be changed."
        }
        
        if myStat == -5046 {
            myStatus.stringValue = "Password does not meet policy requirements."
        }
        
        if myStat == -5999 {
            myStatus.stringValue = "Your Account is restricted. Please see your System Administrator."
        }
        
        if myStat == -5998 {
            myStatus.stringValue = "No Shares are available."
        }
        
        if myStat == -5997 {
            myStatus.stringValue = "-5997 No Authorization Mech Support."
        }
        
        if myStat == -5996 {
            myStatus.stringValue = "-5996 No Protocol Server Support."
        }
        
        if myStat == -6600 {
            myStatus.stringValue = "-6600 Authorizaton: Internal Error."
        }
        
        if myStat == -6602 {
            myStatus.stringValue = "-6602 Error, Mount Failed."
        }
        
        if myStat == -6003 {
            myStatus.stringValue = "-6003 Error, No Shares are Available."
        }
        
        if myStat == -6004 {
            myStatus.stringValue = "-6004 Error, Guest access is Not Supported."
        }
        
        if myStat == -6005 {
            myStatus.stringValue = "-6005 Error, Already Closed."
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myUserName = userDefaults.string(forKey: "userName") {
            userName.stringValue = myUserName
        }
        
        if let myPassword = userDefaults.string(forKey: "Password") {
            Password.stringValue = myPassword
        }
        
        if let myChangePassword = userDefaults.string(forKey: "changePassword") {
            changePassword.state = Int(myChangePassword)!
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func openOptionsDict() -> CFMutableDictionary {
        
        let dict = NSMutableDictionary()
        dict[kNAUIOptionKey] = kNAUIOptionAllowUI
        dict[kNetFSUseGuestKey] = false
        return dict
    }

    
    func mountOptionsDict() -> CFMutableDictionary {
        let dict = NSMutableDictionary()
        return dict
    }
    
    func checkMountPointIntegity(_ shareName: String) -> Int32 {
        myStatus.stringValue = "Share already exists, Cancelling."

        let fm = FileManager.default
        let mountPoint = "/Volumes/" + shareName
        var isDir : ObjCBool = false
        if fm.fileExists(atPath: mountPoint, isDirectory:&isDir) {
            let unMountPt = unmount(mountPoint, 0)
                print("unmountInt: \(unMountPt)")
            return unMountPt
            } else {
            return 0
            }
        }
    
    func asyncMountShare( _ serverAddress: String, shareName: String, userName: String, password: String, shouldChangePassword: Int) {
        let mountPointError = checkMountPointIntegity(shareName)
        if mountPointError == -1 {
            myStatus.stringValue = "It looks like you are already connected to the Server and have some files open on the Server."
            runAppleScript(shareName)
            return
        }
        
        if mountPointError != 0 && mountPointError == -1 {
            myStatus.stringValue = "Mmmmm.. we reached an unknown mount point error: \(mountPointError).. Please Hipchat this your network admin so this condition can be added to a list of known errors. Thank you."
            return
        }
        
        if shouldChangePassword == 1 {
            myStatus.stringValue = "If the change password tool does not 'automagically' appear. On the Popup window, please click the 'Change Password' button on the lower left."
        } else {
                myStatus.stringValue = "Connecting..."
        }
        let escapedAddress = serverAddress.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let shareAddress = URL(string: escapedAddress!)!
        
        let openOptions : CFMutableDictionary = openOptionsDict()
        
        // Currently empty
        let mount_options : CFMutableDictionary = mountOptionsDict()
        
  
        //print (openOptions)
        //let status = false
        var requestID: AsyncRequestID? = nil
        let queue = DispatchQueue.main
 
            
       // NetFSMountURLAsync(shareAddress as CFURL!, nil, userName, password, openOptions, mount_options, &requestID, queue, mount_report)
        
        
        NetFSMountURLAsync(shareAddress as CFURL, nil, userName as NSString, password as NSString, openOptions, mount_options, &requestID, queue,
        {(NetFSMountURLBlock: (myStat:Int32, requestID:AsyncRequestID?, mountpoints:CFArray?)) -> Void in
             print("mounted: \(stat) - \(NetFSMountURLBlock)")
            let myStat = NetFSMountURLBlock.myStat
            let requestID = NetFSMountURLBlock.requestID
            let myMount = NetFSMountURLBlock.mountpoints;
            self.myTest(myStat,requestID:requestID!,myMount:myMount,shareName:shareName)
           })

}

}

