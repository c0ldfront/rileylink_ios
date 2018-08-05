//
//  OmnipodSettingsViewController.swift
//  OmniKitUI
//
//  Created by Pete Schwamb on 8/5/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import UIKit
import RileyLinkKitUI
import OmniKit

class OmnipodSettingsViewController: RileyLinkSettingsViewController {
    
    let pumpManager: OmnipodPumpManager
    
    init(pumpManager: OmnipodPumpManager) {
        self.pumpManager = pumpManager
        super.init(rileyLinkPumpManager: pumpManager, devicesSectionIndex: Section.rileyLinks.rawValue, style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source
    
    private enum Section: Int {
        case info = 0
        case settings
        case rileyLinks
        case delete
        
        static let count = 4
    }

}
