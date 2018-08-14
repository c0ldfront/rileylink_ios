//
//  RileyLinkSetupTableViewController.swift
//  Loop
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import UIKit
import LoopKit
import LoopKitUI
import RileyLinkKit
import RileyLinkBLEKit


public class RileyLinkSetupTableViewController: SetupTableViewController {
    
    var rileyLinkPumpManager: RileyLinkPumpManager?

    var rileyLinkDeviceManager: RileyLinkDeviceManager! {
        didSet {
            let rileyLinkPumpManagerState = RileyLinkPumpManagerState(connectedPeripheralIDs: [])
            
            let rlPumpManager = RileyLinkPumpManager(
                rileyLinkPumpManagerState: rileyLinkPumpManagerState,
                rileyLinkManager: rileyLinkDeviceManager)
            
            let dataSource = RileyLinkDevicesTableViewDataSource(
                rileyLinkPumpManager: rlPumpManager,
                devicesSectionIndex: Section.devices.rawValue
            )
            rileyLinkPumpManager = rlPumpManager
            
            dataSource.tableView = tableView
            dataSource.isScanningEnabled = true
            devicesDataSource = dataSource
        }
    }

    private var devicesDataSource: RileyLinkDevicesTableViewDataSource!

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SetupImageTableViewCell.nib(), forCellReuseIdentifier: SetupImageTableViewCell.className)

        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectionStateDidChange), name: .DeviceConnectionStateDidChange, object: nil)

        updateContinueButtonState()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        devicesDataSource?.isScanningEnabled = true
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        devicesDataSource?.isScanningEnabled = false
    }

    // MARK: - Table view data source

    private enum Section: Int {
        case info
        case devices

        static let count = 2
    }

    private enum InfoRow: Int {
        case image
        case description

        static let count = 2
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .info:
            return InfoRow.count
        case .devices:
            if let dataSource = devicesDataSource {
                return dataSource.tableView(tableView, numberOfRowsInSection: section)
            } else {
                return 0
            }
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .info:
            switch InfoRow(rawValue: indexPath.row)! {
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: SetupImageTableViewCell.className, for: indexPath) as! SetupImageTableViewCell
                cell.mainImageView?.image = VisualDesign.rileyLinkImage(compatibleWith: cell.traitCollection)
                cell.mainImageView?.tintColor = VisualDesign.rileyLinkTint(compatibleWith: cell.traitCollection)
                return cell
            case .description:
                var cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell")
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "DescriptionCell")
                    cell?.selectionStyle = .none
                    cell?.textLabel?.text = NSLocalizedString("RileyLink allows for communication with the pump over Bluetooth Low Energy.", comment: "RileyLink setup description")
                    cell?.textLabel?.numberOfLines = 0
                }
                return cell!
            }
        case .devices:
            return devicesDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .info:
            return nil
        case .devices:
            return devicesDataSource.tableView(tableView, titleForHeaderInSection: section)
        }
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Section(rawValue: section)! {
        case .info:
            return nil
        case .devices:
            return devicesDataSource.tableView(tableView, viewForHeaderInSection: section)
        }
    }

    public override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return devicesDataSource.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - Navigation

    private var shouldContinue: Bool {
        if let dataSource = devicesDataSource {
            return dataSource.rileyLinkPumpManager.rileyLinkPumpManagerState.connectedPeripheralIDs.count > 0
        } else {
            return false
        }
    }

    @objc private func deviceConnectionStateDidChange() {
        DispatchQueue.main.async {
            self.updateContinueButtonState()
        }
    }

    private func updateContinueButtonState() {
        footerView.primaryButton.isEnabled = shouldContinue
    }

    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return shouldContinue
    }

}
