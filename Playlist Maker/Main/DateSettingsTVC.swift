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
    
}


// MARK: - Table View Data Source
extension DateSettingsTVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dateSelectionMode == .range ? 3 : 2  // mode selection + 1 or 2 pickers
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 3 : 1  // 3 modes, 1 picker at a time
    }
    
    /// Display a hint about the section below this title
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Select songs added to your library…"
        }
        if section == 2 {
            return "but also before…"
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
        
        guard section != 0 else { return nil }
        
        switch dateSelectionMode {
        case .before,
             .after:
            return "Date is exclusive"  // can only be for section 1
        case .range:
            return section == 2 ? "Dates are exclusive" : nil
        }
    }

    /// Populates the table view with cells
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the cell to customize
    /// - Returns: Cell with its content, eventually checked
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        let wasInRangeMode = dateSelectionMode == .range
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
        let changesFromRangeMode =  wasInRangeMode && indexPath.row != 2
        let changesToRangeMode   = !wasInRangeMode && indexPath.row == 2
        let updateTable = {
            tableView.reloadSections(IndexSet(integer: 1),     with: .fade)
            if changesFromRangeMode {
                tableView.deleteSections(IndexSet(integer: 2), with: .middle)
            }
            if changesToRangeMode {
                tableView.insertSections(IndexSet(integer: 2), with: .middle)
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
