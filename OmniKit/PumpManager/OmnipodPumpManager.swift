//
//  OmnipodPumpManager.swift
//  OmniKit
//
//  Created by Pete Schwamb on 8/4/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import HealthKit
import LoopKit
import RileyLinkKit
import RileyLinkBLEKit
import os.log

public class OmnipodPumpManager: RileyLinkPumpManager, PumpManager {
    public var pumpBatteryChargeRemaining: Double?
    
    public var pumpRecordsBasalProfileStartEvents = false
    
    public var pumpReservoirCapacity: Double = 200
    
    public var pumpTimeZone: TimeZone {
        return state.podState.timeZone
    }

    public func assertCurrentPumpData() {
        return
    }
    
    public func enactBolus(units: Double, at startDate: Date, willRequest: @escaping (Double, Date) -> Void, completion: @escaping (Error?) -> Void) {
        return
    }
    
    public func enactTempBasal(unitsPerHour: Double, for duration: TimeInterval, completion: @escaping (PumpManagerResult<DoseEntry>) -> Void) {
        return
    }
    
    public func updateBLEHeartbeatPreference() {
        return
    }
    
    public static let managerIdentifier: String = "Omnipod"
    
    public init(state: OmnipodPumpManagerState, rileyLinkManager: RileyLinkDeviceManager?) {
        self.state = state
        
        super.init(rileyLinkPumpManagerState: state.rileyLinkPumpManagerState, rileyLinkManager: rileyLinkManager)
        
        // Pod communication
        self.podComms = PodComms(delegate: self)
    }
    
    public required convenience init?(rawState: PumpManager.RawStateValue) {
        guard let state = OmnipodPumpManagerState(rawValue: rawState) else {
            return nil
        }
        
        self.init(state: state, rileyLinkManager: nil)
    }
    
    public var rawState: PumpManager.RawStateValue {
        return state.rawValue
    }
    
    override public var rileyLinkPumpManagerState: RileyLinkPumpManagerState {
        didSet {
            state.rileyLinkPumpManagerState = rileyLinkPumpManagerState
        }
    }
    
    // TODO: apply lock
    public private(set) var state: OmnipodPumpManagerState {
        didSet {
            pumpManagerDelegate?.pumpManagerDidUpdateState(self)
        }
    }
    
    public weak var pumpManagerDelegate: PumpManagerDelegate?
    
    public let log = OSLog(category: "OmnipodPumpManager")
    
    // MARK: - Pump data
    public static let localizedTitle = NSLocalizedString("Omnipod", comment: "Generic title of the omnipod pump manager")
    
    public var localizedTitle: String {
        return String(format: NSLocalizedString("Omnipod", comment: "Omnipod title"))
    }
    
    override public func deviceTimerDidTick(_ device: RileyLinkDevice) {
        self.pumpManagerDelegate?.pumpManagerBLEHeartbeatDidFire(self)
    }
    
    // MARK: - CustomDebugStringConvertible
    
    override public var debugDescription: String {
        return [
            "## OmnipodPumpManager",
            "pumpBatteryChargeRemaining: \(String(reflecting: pumpBatteryChargeRemaining))",
            "state: \(String(reflecting: state))",
            "",
            "podComms: \(String(reflecting: podComms))",
            "",
            super.debugDescription,
            ].joined(separator: "\n")
    }
    
    // MARK: - Configuration
    
    // MARK: Pump
    
    public private(set) var podComms: PodComms!
    
    // TODO
    public func getStateForDevice(_ device: RileyLinkDevice, completion: @escaping (_ deviceState: DeviceState, _ podComms: PodComms) -> Void) {
        queue.async {
            completion(self.deviceStates[device.peripheralIdentifier, default: DeviceState()], self.podComms)
        }
    }
}



extension OmnipodPumpManager: PodCommsDelegate {
    public func podComms(_ podComms: PodComms, didChange state: PodState) {
        self.state.podState = state
    }
}

