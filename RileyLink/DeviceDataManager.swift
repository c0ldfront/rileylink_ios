//
//  DeviceDataManager.swift
//  RileyLink
//
//  Created by Pete Schwamb on 4/27/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation
import RileyLinkKit
import RileyLinkKitUI
import RileyLinkBLEKit
import MinimedKit
import MinimedKitUI
import NightscoutUploadKit
import LoopKit
import LoopKitUI
import os.log

class DeviceDataManager {

    let rileyLinkDeviceManager: RileyLinkDeviceManager
    
    var pumpManager: PumpManagerUI? {
        didSet {
            pumpManager?.pumpManagerDelegate = self
            UserDefaults.standard.pumpManager = pumpManager
        }
    }

    private var autoConnectPeripheralIDs: Set<String> = Config.sharedInstance().autoConnectIds as! Set<String> {
        didSet {
            Config.sharedInstance().autoConnectIds = autoConnectPeripheralIDs
        }
    }
    
    public let log = OSLog(category: "DeviceDataManager")
    
    init() {
        pumpManager = UserDefaults.standard.pumpManager as? PumpManagerUI
        
        if let rlPumpManager = pumpManager as? RileyLinkPumpManager {
            rileyLinkDeviceManager = rlPumpManager.rileyLinkManager
        } else {
            rileyLinkDeviceManager = RileyLinkDeviceManager(autoConnectIDs: autoConnectPeripheralIDs)
        }
        rileyLinkDeviceManager.setScanningEnabled(true)
    }
}

extension DeviceDataManager: PumpManagerDelegate {
    func pumpManager(_ pumpManager: PumpManager, didAdjustPumpClockBy adjustment: TimeInterval) {
        log.debug("didAdjustPumpClockBy %@", adjustment)
    }
    
    func pumpManagerDidUpdatePumpBatteryChargeRemaining(_ pumpManager: PumpManager, oldValue: Double?) {
    }
    
    func pumpManagerDidUpdateState(_ pumpManager: PumpManager) {
        UserDefaults.standard.pumpManager = pumpManager
    }
    
    func pumpManagerBLEHeartbeatDidFire(_ pumpManager: PumpManager) {
    }
    
    func pumpManagerShouldProvideBLEHeartbeat(_ pumpManager: PumpManager) -> Bool {
        return true
    }
    
    func pumpManager(_ pumpManager: PumpManager, didUpdateStatus status: PumpManagerStatus) {
    }
    
    func pumpManagerWillDeactivate(_ pumpManager: PumpManager) {
        self.pumpManager = nil
    }
    
    func pumpManager(_ pumpManager: PumpManager, didUpdatePumpRecordsBasalProfileStartEvents pumpRecordsBasalProfileStartEvents: Bool) {
    }
    
    func pumpManager(_ pumpManager: PumpManager, didError error: PumpManagerError) {
        log.error("pumpManager didError %@", String(describing: error))
    }
    
    func pumpManager(_ pumpManager: PumpManager, didReadPumpEvents events: [NewPumpEvent], completion: @escaping (_ error: Error?) -> Void) {
    }
    
    func pumpManager(_ pumpManager: PumpManager, didReadReservoirValue units: Double, at date: Date, completion: @escaping (_ result: PumpManagerResult<(newValue: ReservoirValue, lastValue: ReservoirValue?, areStoredValuesContinuous: Bool)>) -> Void) {
    }
    
    func pumpManagerRecommendsLoop(_ pumpManager: PumpManager) {
    }
    
    func startDateToFilterNewPumpEvents(for manager: PumpManager) -> Date {
        return Date().addingTimeInterval(.hours(-2))
    }
    
    func startDateToFilterNewReservoirEvents(for manager: PumpManager) -> Date {
        return Date().addingTimeInterval(.minutes(-15))
    }
}
