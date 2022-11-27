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
    let isReminderOnKey = "isReminderOnKey"
    
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
extension SettingsViewController: SettingCellDelegate {
    
    // SettingCellDelegate protocol implementation
    func toggleSwitchPressed() {
        print("toggle switch was pressed ")
    }
    
    func chevronButtonPressed() {
        print( "chevron button was pressed ")
    }
    func timePickerEditingDidEnd(date: Date) {
        print("Time set for notification to: \(date.description)")
    }
}


