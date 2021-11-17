//
//  NetworkingView.swift
//  RunCat
//
//  Created by Nguyen Ngoc Minh on 11/17/21.
//  Copyright © 2021. All rights reserved.
//

import Cocoa
import Foundation

public class NetworkingView: View {
    
    var notifier: ResizeNotifier?

    private var frames = [NSImage]()
    private var ethernetIconAvailable: NSImage
    private var ethernetIconWaiting: NSImage
    private var frameCount: Int = 0
    private var checkingTimer: Timer? = nil
    private var wiredStatus: NetworkingService.NetworkStatus = .unknown
    private var animationInterval: Double = 0
    private var multiplyFactor: Double = 5
    private var isRunning: Bool = false
    
    private let MIN_PING: Double = 0.01
    
    private let VIEW_WIDTH: CGFloat = 70
    private let VIEW_HEIGHT: CGFloat = 21
    
    private let view: NSView
    private let ethernetView: NSImageView
    private let pingView: NSImageView
    
    private let nwService = NetworkingService()
    
    init() {
        view = NSView(frame: NSMakeRect(0, 0, 32, VIEW_HEIGHT))
        pingView =  NSImageView(frame: NSMakeRect(0, 0, 32, VIEW_HEIGHT))
        pingView.autoresizingMask = [.maxXMargin]
        ethernetView =  NSImageView(frame: NSMakeRect(32, 0, 21, VIEW_HEIGHT))
        ethernetView.autoresizingMask = [.maxXMargin]
        view.autoresizesSubviews = true
        view.addSubview(pingView)
        view.addSubview(ethernetView)
        
        for i in (0 ..< 5) {
            frames.append(NSImage(imageLiteralResourceName: "running_dino_\(i)"))
        }
        frameCount = (frameCount + 1) % frames.count
        self.pingView.image = self.frames[self.frameCount]
        ethernetIconAvailable = NSImage(imageLiteralResourceName: "ethernet_available")
        ethernetIconWaiting = NSImage(imageLiteralResourceName: "ethernet_waiting")
    }
    
    func start() {
        self.isRunning = true
        nwService.startPing()
        var prevResult = false
        checkingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (t) in
            if (self.wiredStatus != self.nwService.getWiredStatus()) {
                self.wiredStatus = self.nwService.getWiredStatus()
                self.animateEthernet()
            }
            let currentPing = self.nwService.getPing()
            self.animationInterval = self.multiplyFactor * currentPing
            if (round(self.animationInterval * 1000) >= 1) {
                self.pingView.toolTip = self.nwService.getTargetHost() + String(format: ": %.1fms", currentPing * 1000)
                prevResult = true
            } else if (prevResult) {
                prevResult = false
                self.pingView.toolTip = self.nwService.getTargetHost() + ": unknown"
            }
        })
        checkingTimer?.fire()
        self.animatePing()
    }
    
    func stop() {
        self.isRunning = false
        nwService.stopPing()
        checkingTimer?.invalidate()
    }
    
    private func animateEthernet() {
        if (self.wiredStatus == .available) {
            self.view.setFrameSize(NSMakeSize(self.pingView.frame.width + self.ethernetView.frame.width, self.view.frame.height))
            self.ethernetView.image = self.ethernetIconAvailable
            notifier?()
        } else if (self.wiredStatus == .estalishing) {
            self.view.setFrameSize(NSMakeSize(self.pingView.frame.width + self.ethernetView.frame.width, self.view.frame.height))
            self.ethernetView.image = self.ethernetIconWaiting
            notifier?()
        } else {
            self.view.setFrameSize(NSMakeSize(self.pingView.frame.width, self.view.frame.height))
            self.ethernetView.image = nil
            notifier?()
        }
    }

    private func animatePing() {
        if (!isRunning) { return }
//        let nextTime = (animationInterval > 0) ? ((animationInterval > minPing) ? animationInterval : minPing) : 0.1
        var nextTime = 0.1
        let roundedInterval = round(animationInterval * 1000)
        if (roundedInterval >= 1) {
            if (animationInterval <= MIN_PING) {
                debugPrint("Weird ping: " + String(format: "%.2f", animationInterval))
                nextTime = MIN_PING
            } else {
                nextTime = animationInterval
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + nextTime) {
            if (roundedInterval >= 1) {
                self.alterFramesPing()
            }
            self.animatePing()
        }
    }
    
    private func alterFramesPing() {
        self.frameCount = (self.frameCount + 1) % self.frames.count
        self.pingView.image = self.frames[self.frameCount]
    }
    
    func getView() -> NSView {
        return view
    }
    
    func getWidth() -> CGFloat {
        return VIEW_WIDTH
    }
    
}
