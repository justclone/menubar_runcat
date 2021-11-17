//
//  AppDelegate.swift
//  Menubar RunCat
//
//  Created by Takuto Nakamura on 2019/08/06.
//  Modified by Nguyen Ngoc Minh on 11/16/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let nc = NSWorkspace.shared.notificationCenter
    private var isRunning: Bool = false
    
    private var viewList = [View]()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = menu
        statusItem.button?.subviews.removeAll()
        
        viewList.append(CpuView())
        viewList.append(NetworkingView())
        
        var prevView: NSView?
        var tempView: NSView
        var totalWidth: CGFloat = 0
        for i in 0..<(viewList.count) {
            var v = viewList[i]
            if (prevView == nil) {
                statusItem.button?.addSubview(v.getView())
            } else {
                tempView = v.getView()
                tempView.setFrameOrigin(NSMakePoint(prevView?.frame.width ?? 0, 0))
                statusItem.button?.addSubview(tempView)
            }
            v.notifier = { () in
                self.resizeStatusBar()
            }
            prevView = v.getView()
            totalWidth += prevView?.frame.width ?? 0
        }
        statusItem.length = totalWidth
        startRunning()
    }
    
    private func resizeStatusBar() {
        var totalWidth: CGFloat = 0
        for v in viewList {
            totalWidth += v.getView().frame.width
        }
        statusItem.length = totalWidth
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopRunning()
    }
    
    func setNotifications() {
        nc.addObserver(self, selector: #selector(AppDelegate.receiveSleepNote),
                       name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(AppDelegate.receiveWakeNote),
                       name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc func receiveSleepNote() {
        stopRunning()
    }
    
    @objc func receiveWakeNote() {
        startRunning()
    }
    
    func startRunning() {
        for v in viewList {
            v.start()
        }
        isRunning = true
    }
    
    func stopRunning() {
        for v in viewList {
            v.stop()
        }
        isRunning = false
    }
    
    @IBAction func showAbout(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

}

