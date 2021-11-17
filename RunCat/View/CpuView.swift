//
//  CpuView.swift
//  RunCat
//
//  Created by Nguyen Ngoc Minh on 11/16/21.
//  Copyright © 2021. All rights reserved.
//

import Cocoa
import Foundation

public class CpuView : View {
    
    var notifier: ResizeNotifier?
    
    private var frames = [NSImage]()
    private var frameCount: Int = 0
    private var checkTimer: Timer? = nil
    private var cpuUsage: (value: Double, description: String) = (0.0, "")
    private var interval: Double = 1.0
    private var isRunning: Bool = false
    
    private var title = ""
    private var view: NSImageView
    
    private let VIEW_WIDTH: CGFloat = 28
    private let VIEW_HEIGHT: CGFloat = 21
    
    private let cpuService = CpuService()
    
    init() {
        view = NSImageView(frame: NSMakeRect(0, 0, VIEW_WIDTH, VIEW_HEIGHT))
        for i in (0 ..< 5) {
            frames.append(NSImage(imageLiteralResourceName: "cat_page\(i)"))
        }
        frameCount = (frameCount + 1) % frames.count
    }
    
    func start() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (t) in
            self.cpuUsage = self.cpuService.usageCPU()
            self.view.toolTip = self.cpuUsage.description
            self.interval = 0.01 * (100 - max(0.0, min(99.0, self.cpuUsage.value))) / 6
        })
        checkTimer?.fire()
        self.isRunning = true
        animate()
    }
    
    func stop() {
        checkTimer?.invalidate()
        self.isRunning = false
    }

    private func animate() {
        if !isRunning { return }
        view.image = frames[frameCount]
        frameCount = (frameCount + 1) % frames.count
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            self.animate()
        }
    }
    
    func getView() -> NSView {
        return view
    }
    
    func getWidth() -> CGFloat {
        return VIEW_WIDTH
    }
    
}
