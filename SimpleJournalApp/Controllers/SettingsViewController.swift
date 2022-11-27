//
//  SettingsViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/15/22.
//

import UIKit

class SettingsViewController: UIViewController, SettingCellDelegate {
    func toggleSwitchPressed() {
        print("toggle switch was pressed ")
    }
    
    func chevronButtonPressed() {
        print( "chevron button was pressed ")
    }
    

    let pref = Preferences()
    let defaults = UserDefaults.standard
    let isReminderOnKey = "isReminderOnKey"
    
    @IBOutlet weak var changeStateButton: UIButton!
    
    @IBAction func changeStateButtonTouched(_ sender: Any) {
        defaults.set(true, forKey: K.UserDefaultsKeys.isReminderEnabled)
        print("Button tapped - changed setting for \(K.UserDefaultsKeys.isReminderEnabled) to true")
    }
    
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
//        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        tableView.reloadData()
        
        
        
        let isReminderOn = defaults.bool(forKey: K.UserDefaultsKeys.isReminderEnabled)
        print("Got the value for isReminderOn sucesfully")
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? SettingCell{
            
            print("retrived cell: \(String(describing: cell.getText()))")
            cell.setToggleButtonState(value: isReminderOn)
        }
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

struct MockupData {
    var settingSection: String?
    var settingsInSection: [(String, String, SettingCell.CellButtonType)]
    /// - settingInSection icon, text and cell button type from enum
    init(settingSection: String? = nil, settingInSection: [(String, String, SettingCell.CellButtonType)]) {
        self.settingSection = settingSection
        self.settingsInSection = settingInSection
    }
    
}

