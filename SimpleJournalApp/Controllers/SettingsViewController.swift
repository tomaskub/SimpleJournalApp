//
//  SettingsViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/15/22.
//

import UIKit

class SettingsViewController: UIViewController {

    // MockupData
    var mockUpSettings = [MockupData]()
    
    let defaults = UserDefaults.standard
    let isReminderOnKey = "isReminderOnKey"
    
    
//    let isReminderOn: Bool = {
//        return defaults.bool(forKey: isReminderOnKey)
//    }()

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.setValue(true, forKey: "isReminderOn")
        //TODO: Remove mock up after settings integration
        //Mockup data
        mockUpSettings.append(MockupData(settingSection: "Privacy", settingInSection: [
            ("eye", "Track data", .withToggleSwitch),
            ("figure.track.motion", "Tack location", .withToggleSwitch),
            ("hand.raised", "Send failure reports", .withToggleSwitch)]))
        mockUpSettings.append(MockupData(settingSection: "Color", settingInSection: [
            ("circle.lefthalf.filled", "Use dark theme all the time", .withToggleSwitch),
            ("pencil.tip.crop.circle", "Use custom colors", .withChevronRight),
            ("figure.2.arms.open", "Use other user template", .withChevronRight),
//            ("Randomly change template everyday")
        ]))
        mockUpSettings.append(MockupData(settingSection: "Reminders", settingInSection: [
            ("clock.circle", "Set up reminder to journal", . withToggleSwitch),
            ("clock.circle", "Time to journal", .withToggleSwitch),
            ("calendar.badge.plus", "Create a calendar event for journaling", .withToggleSwitch),
            ("r.circle", "Create a Reminder in Apple reminders", .withToggleSwitch)
        ]))
        
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
        return mockUpSettings[section].settingsInSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier) as! SettingCell
        let iconName = mockUpSettings[indexPath.section].settingsInSection[indexPath.row].0
        let labelText = mockUpSettings[indexPath.section].settingsInSection[indexPath.row].1
        let cellType = mockUpSettings[indexPath.section].settingsInSection[indexPath.row].2
        cell.configureCell(iconSystemName: iconName, labelText: labelText, cellType: cellType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mockUpSettings.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mockUpSettings[section].settingSection
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

