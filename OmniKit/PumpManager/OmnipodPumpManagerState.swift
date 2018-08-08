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
    
    public init(podState: PodState, rileyLinkPumpManagerState: RileyLinkPumpManagerState) {
        self.podState = podState
        self.rileyLinkPumpManagerState = rileyLinkPumpManagerState
    }
    
    public init?(rawValue: RawValue) {
        guard
            let podStateRaw = rawValue["podState"] as? PodState.RawValue,
            let rileyLinkPumpManagerStateRaw = rawValue["rileyLinkPumpManagerState"] as? RileyLinkPumpManagerState.RawValue,
            let podState = PodState(rawValue: podStateRaw),
            let rileyLinkPumpManagerState = RileyLinkPumpManagerState(rawValue: rileyLinkPumpManagerStateRaw)
            else
        {
            return nil
        }
        
        self.init(
            podState: podState,
            rileyLinkPumpManagerState: rileyLinkPumpManagerState
        )
    }
    
    public var rawValue: RawValue {
        return [
            "podState": podState.rawValue,
            "rileyLinkPumpManagerState": rileyLinkPumpManagerState.rawValue,
            
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
            String(reflecting: rileyLinkPumpManagerState),
            ].joined(separator: "\n")
    }
}
