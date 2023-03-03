//
//  ViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//
import CoreData
import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    var journalManager: JournalManager?
    var reminderManager: ReminderManager?
    var selectedDayLog: DayLog?
    
    var collapsedSections: Set<Int> = []
    
    var selectedDate: Date = Date()
    //Declare calendar buttons in an array
    let dateButtonArray: [CalendarDayButton] = {
        
        var tempArray: [CalendarDayButton] = []
            
        for i in 0...7 {
                let button: CalendarDayButton = {
                    let date = Calendar.current.date(byAdding: .day, value: -4+i, to: Date.now)
                    let button = CalendarDayButton(date: date!)//, isToday: false)
                    if i == 4 {
                        button.isTodayButton = true
                        button.isSelected = true
                    }
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.addTarget(self, action: #selector(setSelected(sender:)), for: .touchUpInside)
                    return button
            }()
                tempArray.append(button)
        }
        return tempArray
    }()
    
    // Properties for reminders (empty section to trick the manager, so the indexPath works without extra logic and in tableview dataSource method different source is injected)
    let sectionNames = ["To-do today:", "", "To-do tomorrow:"]
    let comparators: [(Reminder) -> Bool] = [
        { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            } else { return false }
        },
        { reminder in
            return false
        },
        { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInTomorrow(dueDate)
            } else { return false }
        }]
    
    
    //MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        performFirstTimeSetUp()
        
        journalManager = JournalManager(managedObjectContext: managedContext, coreDataStack: coreDataStack)
        reminderManager =  ReminderManager(sectionNames: sectionNames, comparators: comparators)
        
        reminderManager?.delegate = self
        do {
            try reminderManager!.prepareReminderStore()
        } catch {
            print(error.localizedDescription)
        }
        
        let results = journalManager?.getEntry(for: Date())
        //this needs to change to throw method probably?
        if let error = results?.error as? JournalManagerNSError, error == .noResultsRetrived {
            selectedDayLog = nil
        } else {
            selectedDayLog = results?.dayLogs.first
        }

        layoutUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        tableView.register(ReminderTableViewCell.self, forCellReuseIdentifier: ReminderTableViewCell.identifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let offsetX = scrollView.contentSize.width / 2
        scrollView.setContentOffset(CGPoint(x: offsetX , y: 0 ), animated: true)
        if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.useDarkTheme) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .unspecified
        }
    }
    //MARK: Selectors
    @objc func setSelected(sender: UIButton) {
        
        for button in dateButtonArray {
            button.isSelected = false
        }
        sender.isSelected = true
        selectedDate = (sender as! CalendarDayButton).getDate()
        let results = journalManager?.getEntry(for: selectedDate)
        //this needs to change
        if let error = results?.error as? JournalManagerNSError, error == .noResultsRetrived {
//            selectedDayLog = journalManager?.addEntry(date)
            selectedDayLog = nil
        } else {
            selectedDayLog = results?.dayLogs.first
        }
        tableView.reloadData()
    }
    
    @objc func collapseExpandSection(sender: UIButton) {
        
        guard let tableView = self.tableView else { return }
        
        guard let headerView = sender.superview?.superview as? HeaderView else { print("failed to get superview")
            return
        }
        
        let sectionNumber: Int? = {
            for i in 0...tableView.numberOfSections {
                if tableView.headerView(forSection: i) == headerView {
                    return i
                }
            }
            return nil
        }()
        guard let sectionNumber = sectionNumber else { return }
        
        // temp for testing:
        
//        guard sectionNumber == 1 else { return }
        
        print("section number: \(sectionNumber), titled: \(headerView.titleLabel.text!) changed its collapse - expand state")
        
        var image: UIImage?
        if collapsedSections.contains(sectionNumber) {
            // insert rows
            collapsedSections.remove(sectionNumber)
            
            var indexesToAdd = [IndexPath]()
            
            let numberOfCells: Int = {
                if sectionNumber == 1 {
                    return K.actions.count
                } else {
                    return reminderManager?.sections[sectionNumber].numberOfObjects ?? 0
                }
            }()
            
            if !(numberOfCells == 0){
                for i in 0...numberOfCells - 1 {
                    indexesToAdd.append(IndexPath(row: i, section: sectionNumber))
                }
                tableView.insertRows(at: indexesToAdd, with: .fade)
            }
            
            image = UIImage(systemName: "chevron.up")
        } else {
            collapsedSections.insert(sectionNumber) // set before removing rows
            
            var indexesToRemove = [IndexPath]()
            if !(tableView.numberOfRows(inSection: sectionNumber) == 0) {
                
                for i in 0...tableView.numberOfRows(inSection: sectionNumber) - 1 {
                    indexesToRemove.append(IndexPath(row: i, section: sectionNumber))
                }
                
                tableView.deleteRows(at: indexesToRemove, with: .fade)
                
            }
            
            image = UIImage(systemName: "chevron.down")
        }
        
        sender.setImage(image, for: .normal)
    }
    
    
//    MARK: UI layout
    func layoutUI(){
        //adjust tableview appearance
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.frame.width / 20
        // configure date label text
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        // set up constraints for calendar buttons
        for i in 0...dateButtonArray.count-1 {
            scrollView.addSubview(dateButtonArray[i])
            if i == 0 {
                dateButtonArray[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
            } else {
                dateButtonArray[i].leadingAnchor.constraint(equalTo: dateButtonArray[i-1].trailingAnchor, constant: 10).isActive = true
            }
            NSLayoutConstraint.activate([
                dateButtonArray[i].topAnchor.constraint(equalTo: scrollView.topAnchor),
                dateButtonArray[i].bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                dateButtonArray[i].widthAnchor.constraint(equalToConstant: scrollView.frame.height * 0.85),
                dateButtonArray[i].heightAnchor.constraint(equalToConstant: scrollView.frame.height)
            ])
        }
        dateButtonArray.last?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 10).isActive = true
    }

    //MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // preparation fo a segue triggered by question cell button
        if segue.identifier == K.SegueIdentifiers.toQuestionVC {
            let targetVC = segue.destination as! EntryViewController
            if let dayLog = selectedDayLog {
                targetVC.dayLog = dayLog
                targetVC.managedContext = managedContext
                targetVC.journalManager = journalManager
                targetVC.strategy = .isCreatingNewEntry
            }
        }
    }
}

//MARK: initial setup
extension MainViewController {
    
    func performFirstTimeSetUp(){
        
        let preferences = Preferences()
        let defaults = UserDefaults.standard
        
        if !defaults.bool(forKey: K.UserDefaultsKeys.wasRunBefore) {
            
            print("Performing first time set up!")
            
            for section in preferences.settings {
                for setting in section.settingInSection {
                    if let key = setting.key {
                        if setting.key != K.UserDefaultsKeys.isTrackDataEnabled && setting.key != K.UserDefaultsKeys.sendFailureReports {
                            defaults.set(false, forKey: key)
                            print("Setting set to false for key \(key)")
                        } else {
                            defaults.set(true, forKey: key)
                            print("Setting set to true for \(key)")
                        }
                    }
                }
            }
            defaults.set(true, forKey: K.UserDefaultsKeys.wasRunBefore)
        }
    }
}

//MARK: Table view methods
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var result: CGFloat = tableView.frame.height / 8
        if indexPath.section == 1 && indexPath.row == 0 && selectedDayLog?.photo != nil {
            result = 5 * tableView.frame.height / 8
        }
        return result
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reminderManager?.numberOfSections ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as! HeaderView
        switch section {
        case 1:
            header.titleLabel.text = "Actions"
            header.plusButton.removeFromSuperview()
            header.chevronButton.addTarget(self, action: #selector(collapseExpandSection(sender:)), for: .touchUpInside)
        default:
            header.titleLabel.text = reminderManager?.sectionTitles[section] ?? "Section \(section)"
            header.plusButton.addTarget(self, action: #selector(presentReminderDetailView), for: .touchUpInside)
            header.chevronButton.addTarget(self, action: #selector(collapseExpandSection(sender:)), for: .touchUpInside)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if collapsedSections.contains(section) {
            return 0
        } else {
            if section == 1 {
                return K.actions.count
            } else {
                return reminderManager?.sections[section].numberOfObjects ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            if indexPath.row == 0, let data = selectedDayLog?.photo  {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
                cell.delegate = self
                cell.myImageView.image = UIImage(data: data)
                cell.cornerRadius = 20
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
                cell.configureCell(with: K.actions[indexPath.row])
                cell.selectionStyle = .none
                cell.cornerRadius = 20
                return cell
                
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
            if let reminderManager = reminderManager {
            do {
                let reminder = try reminderManager.reminder(forIndexPath: indexPath)
                cell.configureCell(with: reminder.title, buttonState: reminder.isComplete)
                cell.delegate = self
            } catch {
                print(error)
            }}
            return cell
        }
    }
    
    fileprivate func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    @objc fileprivate func presentReminderDetailView() {
        let reminder = Reminder()
        let vc = DetailViewController()
        vc.reminder = reminder
        vc.isAddingNewReminder = false
        vc.reminderManager = reminderManager
        
        present(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //need to implement unwrapping the day log to make sure that it is added only when an action is tapped
        if indexPath.section == 1 {
            switch indexPath.row {
                
            case 0:
                if selectedDayLog == nil {
                    let result = journalManager?.getEntry(for: selectedDate)
                    if let error = result?.error as? JournalManagerNSError, error == .noResultsRetrived {
                        selectedDayLog = journalManager?.addEntry(selectedDate)
                    } else {
                        selectedDayLog = result?.dayLogs.first
                    }
                }
                presentPhotoPicker()
            case 1:
                if selectedDayLog == nil {
                    let result = journalManager?.getEntry(for: selectedDate)
                    if let error = result?.error as? JournalManagerNSError, error == .noResultsRetrived {
                        selectedDayLog = journalManager?.addEntry(selectedDate)
                    } else {
                        selectedDayLog = result?.dayLogs.first
                    }
                }
                let sender = tableView.cellForRow(at: indexPath)
                performSegue(withIdentifier: K.SegueIdentifiers.toQuestionVC, sender: sender)
            default:
                print("Add reminders cell tapped!")
                tableView.reloadData()
            }
        } else {
            do {
                //does not update the
                let reminder = try reminderManager?.reminder(forIndexPath: indexPath)
                let vc = DetailViewController()
                vc.reminder = reminder
                vc.isAddingNewReminder = false
                vc.reminderManager = reminderManager
                present(vc, animated: true)
            } catch {
                print(error)
            }
            
        }
        
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let data = image.jpegData(compressionQuality: 1.0),
                    let log = selectedDayLog,
                  let manager = journalManager else { return }
            manager.addPhoto(jpegData: data, to: log)
        }
        tableView.reloadData()
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
}

extension MainViewController: PhotoCellDelegate {
    func leftButtonTapped() {
        presentPhotoPicker()
    }
    func rightButtonTapped() {
        guard let entry = selectedDayLog, let _journalManager = journalManager else { return }
        _journalManager.deletePhoto(entry: entry)
        tableView.reloadData()
    }
}

//MARK: ReminderManagerDelegate methods
extension MainViewController: ReminderManagerDelegate {
    func requestUIUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func controllerWillChangeContent(_ controller: ReminderManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(_ controller: ReminderManager) {
        DispatchQueue.main.async {
            self.tableView.endUpdates()
        }
    }
    
    func controller(_ controller: ReminderManager, didChange aReminder: Reminder, at indexPath: IndexPath?, for type: ReminderManagerChangeType, newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                if !self.collapsedSections.contains(newIndexPath!.section) {
                        self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
                    }
            case .delete:
                if !self.collapsedSections.contains(indexPath!.section) {
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            }
            case .move:
                
                if !self.collapsedSections.contains(indexPath!.section) {
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                }
                
                if !self.collapsedSections.contains(newIndexPath!.section) {
                self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
                }
                
            case .update:
                if !self.collapsedSections.contains(indexPath!.section) {
                    if let cell = self.tableView.cellForRow(at: indexPath!) as? ReminderTableViewCell {
                        cell.configureCell(buttonState: aReminder.isComplete)
                    }
                }
            }
        }
    }
    
    func controller(_ controller: ReminderManager, didChange sectionInfo: ReminderResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: ReminderManagerChangeType) {
    }
    
    
}

extension MainViewController: ReminderTableViewCellDelegate {
    
    func doneButtonTapped(sender: ReminderTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            do {
                try reminderManager?.updateReminder(atIndexPath: indexPath)
            } catch {
                print(error)
            }
        }
    }
}
