//
//  DateSettingsTVC.swift
//  Playlist Maker
//
//  Created by Tomn on 02/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    /// One of the date pickers value changed
    static let datePickerValueChanged = #selector(DateSettingsTVC.datePickerValueChanged(_:))
    /// One of the switches value changed
    static let     switchValueChanged = #selector(DateSettingsTVC.switchValueChanged(_:))
}


/// View controller allowing the user to select a time range.
/// 1st section controls the mode of selection of this range:
///   ]–∞;date[ or ]date;+∞[ or ]date1;date2[
/// 2nd section allows editing this range with a date.
/// 3rd section is used when the user is required to enter 2 dates.
class DateSettingsTVC: UITableViewController {
    
    /// Current preference for date mode in song selection input
    var dateSelectionMode = DateSelectionMode(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKey.dateSelectionMode)) ?? .after {
        didSet {
            UserDefaults.standard.set(dateSelectionMode.rawValue,
                                      forKey: UserDefaultsKey.dateSelectionMode)
        }
    }
    
    
    /// Called when the date value of one of the picker(s) changed
    ///
    /// - Parameter sender: Picker, hopefully, whose value changed
    @objc func datePickerValueChanged(_ sender: AnyObject) {
        
        guard let picker = sender as? UIDatePicker else { return }
        let date = picker.date
        
        /* Save date in settings */
        if picker.tag == DateSelectionMode.before.rawValue {
            DataStore.shared.dateSelectionModeEnd   = date
            
        } else if picker.tag == DateSelectionMode.after.rawValue {
            DataStore.shared.dateSelectionModeStart = date
        }
    }
    
    /// Called when the boolean value of one of the switch(es) changed
    ///
    /// - Parameter sender: Switch, hopefully, whose value changed
    @objc func switchValueChanged(_ sender: AnyObject) {
        
        guard let `switch` = sender as? UISwitch else { return }
        
        if `switch`.tag == 0 {
            UserDefaults.standard.set(`switch`.isOn,
                                      forKey: UserDefaultsKey.dateSelectionUpdates)
        }
    }
    
}


// MARK: - Table View Data Source
extension DateSettingsTVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dateSelectionMode != .before ? 3 : 2  // mode selection + 1 or 2 pickers + settings if .after
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 3 : 1  // 3 modes, 1 picker at a time, 1 setting
    }
    
    /// Display a hint about the section below this title
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Select songs added to your library…"
        }
        if section == 2 {
            return dateSelectionMode == .range ? "but also before…" : nil
        }
        
        // Section 1
        switch dateSelectionMode {
        case .before:
            return "All songs added before…"
        case .after,
             .range:
            return "All songs added after…"
        }
    }
    
    /// Display a hint about dates at the bottom of the table
    override func tableView(_ tableView: UITableView,
                            titleForFooterInSection section: Int) -> String? {
        
        if section == 2 && dateSelectionMode == .after {
            return "Allows you, the next time you open the app with new songs in your library, to only sort those ones.\nAlso allows you to resume any sorting process you stopped."
        }
        return nil
    }

    /// Populates the table view with cells
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the cell to customize
    /// - Returns: Cell with its content, eventually checked
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // SELECTABLE TEXT
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell",
                                                     for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Before date"
                cell.accessoryType   = dateSelectionMode == .before ? .checkmark : .none
                
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "After date"
                cell.accessoryType   = dateSelectionMode == .after  ? .checkmark : .none
                
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Between dates"
                cell.accessoryType   = dateSelectionMode == .range  ? .checkmark : .none
            }
            
            return cell
        }
        
        // SWITCH
        if indexPath.section == 2 && dateSelectionMode == .after {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell",
                                                     for: indexPath) as! DateSettingsSwitchCell
            
            cell.switch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.dateSelectionUpdates)
            cell.switch.addTarget(self, action: .switchValueChanged, for: .valueChanged)
            
            return cell
        }
        
        // PICKER
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell",
                                                 for: indexPath)
        
        if let pickerCell = cell as? DateSettingsPickerCell {
            pickerCell.picker.maximumDate = Date()
            pickerCell.pickerMode = (dateSelectionMode == .before ||
                                     indexPath.section == 2) ? .before : .after
            pickerCell.picker.addTarget(self, action: .datePickerValueChanged,
                                        for: .valueChanged)
        }

        return cell
    }

}

extension DateSettingsTVC {
    
    /// User tapped a row
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the row tapped
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Only the 1st section can be tapped, the others are pickers
        guard indexPath.section == 0 else { return }
        
        /* Update mode in model */
        let previousMode = dateSelectionMode
        switch indexPath.row {
        case 0:
            dateSelectionMode = .before
        case 1:
            dateSelectionMode = .after
        case 2:
            dateSelectionMode = .range
        default:
            return
        }
        
        /* Change display mode in Sections 1 & 2 */
        let wasInBeforeMode         = previousMode == .before
        let changesFromBeforeMode   =  wasInBeforeMode && dateSelectionMode != .before
        let changesToBeforeMode     = !wasInBeforeMode && dateSelectionMode == .before
        let changesBtwAfterAndRange = (previousMode == .after && dateSelectionMode == .range) ||
                                      (previousMode == .range && dateSelectionMode == .after)
        let updateTable = {
            tableView.reloadSections(IndexSet(integer: 1),     with: .fade)
            if changesToBeforeMode {
                tableView.deleteSections(IndexSet(integer: 2), with: .middle)
            }
            if changesFromBeforeMode {
                tableView.insertSections(IndexSet(integer: 2), with: .middle)
            }
            if changesBtwAfterAndRange {
                tableView.reloadSections(IndexSet(integer: 2), with: .fade)
            }
        }
        // Apply
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates(updateTable)
        } else {
            tableView.beginUpdates()
            updateTable()
            tableView.endUpdates()
        }
        
        /* Section 0 */
        // Deselect all rows
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            tableView.cellForRow(at: IndexPath(row: row,
                                               section: 0))?.accessoryType = .none
        }
        
        // Select requested row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
}


// MARK: - Picker Cell
/// Cell for DateSettingsTVC.
/// Simply a cell containing a date picker.
class DateSettingsPickerCell: UITableViewCell {
    
    /// Mode associated to the picker
    var pickerMode: DateSelectionMode = .after {
        didSet {
            /* Save mode so the view controller can
             idenfity it back when saving changes */
            picker.tag = pickerMode.rawValue
            
            /* Load initial date according to picker mode */
            switch pickerMode {
            case .before:
                picker.date = DataStore.shared.dateSelectionModeEnd
            case .after:
                picker.date = DataStore.shared.dateSelectionModeStart
            case .range:   // Not supported
                picker.date = Date()
            }
        }
    }
    
    @IBOutlet weak var picker: UIDatePicker!
    
}



// MARK: - Switch Cell
/// Cell for DateSettingsTVC.
/// Contains a text label and a UISwitch.
class DateSettingsSwitchCell: UITableViewCell {
    
    @IBOutlet weak var `switch`: UISwitch!
    
}

