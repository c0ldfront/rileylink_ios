//
//  OmnipodPumpManagerSetupViewController.swift
//  OmniKitUI
//
//  Created by Pete Schwamb on 8/4/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import Foundation

import UIKit
import LoopKit
import LoopKitUI
import OmniKit
import RileyLinkBLEKit
import RileyLinkKit
import RileyLinkKitUI

public class OmnipodPumpManagerSetupViewController: RileyLinkManagerSetupViewController {
    
    class func instantiateFromStoryboard() -> OmnipodPumpManagerSetupViewController {
        return UIStoryboard(name: "OmnipodPumpManager", bundle: Bundle(for: OmnipodPumpManagerSetupViewController.self)).instantiateInitialViewController() as! OmnipodPumpManagerSetupViewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationBar.shadowImage = UIImage()
    }
    
    private(set) var pumpManager: OmnipodPumpManager?
    
    /*
     1. RileyLink
     - RileyLinkPumpManagerState
     
     2. Pod Pairing/Priming
     
     3. Basal Rates & Delivery Limits
     
     4. Cannula Insertion
     
     5. Pump Setup Complete
     */
    
    func completeSetup() {
        if let pumpManager = pumpManager {
            setupDelegate?.pumpManagerSetupViewController(self, didSetUpPumpManager: pumpManager)
        }
    }
}
