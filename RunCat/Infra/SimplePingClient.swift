//
//  SimplePingClient.swift
//  RunCat
//
//  Created by Nguyen Ngoc Minh on 11/17/21.
//  Copyright © 2021. All rights reserved.
//

import Foundation
import QuartzCore

public typealias SimplePingClientCallback = (Double?)->()

public class SimplePingClient: NSObject {
    private static let _instance = SimplePingClient()

    private var resultCallback: SimplePingClientCallback?
    private var pingClient: SimplePing?
    private var hostname: String?
    private var client: SimplePing?
    private var canPing: Bool = false
    private var seqMap: [UInt16: Double] = [:]

    public static func ping(hostname: String, andResultCallback callback: SimplePingClientCallback?) {
        _instance.setHostname(hostname: hostname)
        _instance.ping(andResultCallback: callback)
    }

    public func ping(andResultCallback callback: SimplePingClientCallback?) {
        resultCallback = callback
        if (canPing) {
            client?.send(with: nil)
        }
    }
    
    public func setHostname(hostname: String) {
        if (self.hostname == nil) {
            self.hostname = hostname
            client = SimplePing(hostName: hostname)
            client?.delegate = self
            client?.start()
        }
    }
    
    public static func stop() {
        _instance.stop()
    }
    
    public func stop() {
        client?.stop()
        self.hostname = nil
        client = nil
    }
}

extension SimplePingClient: SimplePingDelegate {
    public func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        canPing = true
    }

    public func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        debugPrint("Failed: " + String(reflecting: error))
        canPing = false
        resultCallback?(nil)
    }

    public func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        seqMap[sequenceNumber] = ProcessInfo.processInfo.systemUptime
    }

    public func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        self.seqMap[sequenceNumber] = nil
        resultCallback?(nil)
    }

    public func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        resultCallback?(nil)
    }

    public func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let timeDiff = self.seqMap[sequenceNumber] else { return }
        self.seqMap[sequenceNumber] = nil
        let latency = ProcessInfo.processInfo.systemUptime - timeDiff
        debugPrint(latency)
        resultCallback?(latency)
    }
}
