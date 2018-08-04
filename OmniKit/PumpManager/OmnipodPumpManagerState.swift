//
//  OmnipodPumpManagerState.swift
//  OmniKit
//
//  Created by Pete Schwamb on 8/4/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import RileyLinkKit
import RileyLinkBLEKit
import LoopKit

public struct OmnipodPumpManagerState: RawRepresentable, Equatable {
    public typealias RawValue = PumpManager.RawStateValue
    
    public static let version = 1
    
    public var podState: PodState
    
    public var rileyLinkPumpManagerState: RileyLinkPumpManagerState
    
    public var timeZone: TimeZone
    
    public init(podState: PodState, rileyLinkPumpManagerState: RileyLinkPumpManagerState, timeZone: TimeZone) {
        self.podState = podState
        self.rileyLinkPumpManagerState = rileyLinkPumpManagerState
        self.timeZone = timeZone
    }
    
    public init?(rawValue: RawValue) {
        guard
            let podStateRaw = rawValue["podState"] as? PodState.RawValue,
            let rileyLinkPumpManagerStateRaw = rawValue["rileyLinkPumpManagerState"] as? RileyLinkPumpManagerState.RawValue,
            let timeZoneSeconds = rawValue["timeZone"] as? Int,
            
            let podState = PodState(rawValue: podStateRaw),
            let rileyLinkPumpManagerState = RileyLinkPumpManagerState(rawValue: rileyLinkPumpManagerStateRaw),
            let timeZone = TimeZone(secondsFromGMT: timeZoneSeconds)
            else {
                return nil
        }
        
        self.init(
            podState: podState,
            rileyLinkPumpManagerState: rileyLinkPumpManagerState,
            timeZone: timeZone
        )
    }
    
    public var rawValue: RawValue {
        return [
            "podState": podState.rawValue,
            "rileyLinkPumpManagerState": rileyLinkPumpManagerState.rawValue,
            "timeZone": timeZone.secondsFromGMT(),
            
            "version": OmnipodPumpManagerState.version,
        ]
    }
}


extension OmnipodPumpManagerState {
    static let idleListeningEnabledDefaults: RileyLinkDevice.IdleListeningState = .enabled(timeout: .minutes(4), channel: 0)
}


extension OmnipodPumpManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        return [
            "## MinimedPumpManagerState",
            String(reflecting: podState),
            "timeZone: \(timeZone)",
            String(reflecting: rileyLinkPumpManagerState),
            ].joined(separator: "\n")
    }
}
