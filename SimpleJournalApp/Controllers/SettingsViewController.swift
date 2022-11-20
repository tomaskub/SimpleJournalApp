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
        mockUpSettings.append(MockupData(settingSection: "Privacy", settingInSection: ["Track data", "Tack location", "Send failure reports"]))
        mockUpSettings.append(MockupData(settingSection: "Color", settingInSection: ["Use dark theme all the time", "Use custom colors", "Use other user template", "Randomly change template everyday"]))
        mockUpSettings.append(MockupData(settingSection: "Reminders", settingInSection: ["Set up reminder to journal", "Time to journal", "Create a calendar event for journaling", "Create a Reminder in Apple reminders"]))
        
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
        cell.configureCell(iconImage: UIImage(systemName: "clock") ?? UIImage(), labelText: "Set reminder")//, buttonImage: UIImage(named: "clock.fill")!)
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
    var settingsInSection: [String]
    
    init(settingSection: String? = nil, settingInSection: [String]) {
        self.settingSection = settingSection
        self.settingsInSection = settingInSection
    }
    
}

