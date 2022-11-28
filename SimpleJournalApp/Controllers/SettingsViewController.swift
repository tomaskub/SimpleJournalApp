//
//  SettingsViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/15/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let pref = Preferences()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display date
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        
        //set up table view appearance
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.bounds.width / 10
        tableView.rowHeight = 80
        
        //set up tableView protocols
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pref.settings[section].settingInSection.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier) as! SettingCell
        let iconName = pref.settings[indexPath.section].settingInSection[indexPath.row].icon
        let labelText = pref.settings[indexPath.section].settingInSection[indexPath.row].text
        let cellType = pref.settings[indexPath.section].settingInSection[indexPath.row].type
        cell.configureCell(iconSystemName: iconName, labelText: labelText, cellType: cellType)
        cell.delegate = self
        //test - get the value of a bool for key
        if cellType == .withToggleSwitch {
            cell.setToggleButtonState(value: defaults.bool(forKey: pref.settings[indexPath.section].settingInSection[indexPath.row].key))
        }
        if cellType == .withTimePicker {
            if let date = defaults.value(forKey: pref.settings[indexPath.section].settingInSection[indexPath.row].key) as? Date{
                cell.setTime(date: date)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pref.settings.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pref.settings[section].sectionName
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
// SettingCellDelegate protocol implementation
extension SettingsViewController: SettingCellDelegate {
    
    func chevronButtonPressed(sender: SettingCell) {
        //placeholder
        print(tableView.indexPath(for: sender)?.debugDescription)
        
    }
    
    func toggleSwitchPressed(sender: SettingCell) {
        
        if let indexPath = tableView.indexPath(for: sender) {
            let key = pref.settings[indexPath.section].settingInSection[indexPath.row].key
            defaults.setValue(sender.getToggleButtonState(), forKey: key)
        } else {
            print("getting index path for sender setting cell failed at toggleSwitchPressed(sender: \(sender.description)")
        }
        
        
    }
    
    func timePickerEditingDidEnd(sender: SettingCell) {
        if let indexPath = tableView.indexPath(for: sender){
            if let date = sender.getTime() {
                let key = pref.settings[indexPath.section].settingInSection[indexPath.row].key
                defaults.setValue(date, forKey: key)
            }
        }
        
    }
}


