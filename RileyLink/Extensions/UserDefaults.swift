//
//  UserDefaults.swift
//  RileyLink
//
//  Copyright © 2017 Pete Schwamb. All rights reserved.
//

import Foundation
import LoopKit
import RileyLinkKit

extension UserDefaults {
    private enum Key: String {
        case pumpManagerState = "com.rileylink.PumpManagerState"
    }
    
    var pumpManager: PumpManager? {
        get {
            guard let rawValue = dictionary(forKey: Key.pumpManagerState.rawValue) else {
                return nil
            }
            
            return PumpManagerFromRawValue(rawValue)
        }
        set {
            set(newValue?.rawValue, forKey: Key.pumpManagerState.rawValue)
        }
    }
}

