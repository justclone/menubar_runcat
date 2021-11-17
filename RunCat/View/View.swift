//
//  View.swift
//  RunCat
//
//  Created by Nguyen Ngoc Minh on 11/17/21.
//  Copyright © 2021. All rights reserved.
//

import Cocoa
import Foundation

public typealias ResizeNotifier = () -> Void

protocol View {
    var notifier: ResizeNotifier? { get set }
    func start()
    func stop()
    func getView() -> NSView
    func getWidth() -> CGFloat
}
