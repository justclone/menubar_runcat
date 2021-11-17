//
//  Networking.swift
//  RunCat
//
//  Created by Nguyen Ngoc Minh on 11/14/21.
//  Copyright © 2021. All rights reserved.
//

import Foundation
import Cocoa
import SystemConfiguration
import Network

public class NetworkingService {
    
    private static let processName: NSString = Bundle.main.infoDictionary!["CFBundleName"] as! CFString
    private let monitorQueue = DispatchQueue(label: NetworkingService.processName as String)
    
    private var nwStatus: NetworkStatus = .unknown
    private var nwPing: Double = 0
    private var isRunning: Bool = false
    
    private let TARGET_HOST = "ipv4.google.com"
    
    init() {
        if #available(macOS 10.14, *) {
            initWiredEthernetMonitor()
        } else {
            initNetworkChangedCallback()
        }
    }
    
    public func getWiredStatus() -> NetworkStatus {
        return self.nwStatus
    }
    
    public func getPing() -> Double {
        return self.nwPing
    }
    
    public func getTargetHost() -> String {
        return self.TARGET_HOST
    }
    
    public func startPing() {
        self.isRunning = true
        self.ping()
    }
    
    public func stopPing() {
        self.isRunning = false
        SimplePingClient.stop()
    }
    
    private func ping(minWait: Double = 1) { // 1s
        if (!isRunning) { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + minWait) {
            if (!self.isRunning) { return }
            SimplePingClient.ping(hostname: self.TARGET_HOST) { latency in
                self.nwPing = latency ?? 0
                self.ping()
            }
        }
    }
    
    private func onChange(status: NetworkStatus) {
        if (self.nwStatus != status) {
            self.nwStatus = status
            debugPrint("Wired status changed: " + String(reflecting: status))
        }
    }
    
    @available(OSX 10.14, *)
    private func initWiredEthernetMonitor() {
        let nwMonitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)
        nwMonitor.pathUpdateHandler = { path in
            self.switchNetworkStatus(path: path)
        }
        nwMonitor.start(queue: monitorQueue)
    }
    
    @available(OSX 10.14, *)
    private func switchNetworkStatus(path: NWPath) {
        switch (path.status) {
        case .satisfied:
            print("Wired ethernet established")
            self.onChange(status: .available)
            break
        case .unsatisfied:
            print("Wired ethernet unavailable")
            self.onChange(status: .unavailable)
            break
        case .requiresConnection:
            print("Wired ethernet establishing")
            self.onChange(status: .estalishing)
            break
        @unknown default:
            print("Wired ethernet status unknown")
            self.onChange(status: .unknown)
            break
        }
    }
    
    private func initNetworkChangedCallback() {
        // TODO on network change
        debugPrint("Later")
    }
    
    public enum NetworkStatus {
        case available
        case estalishing
        case unavailable
        case unknown
    }

}
