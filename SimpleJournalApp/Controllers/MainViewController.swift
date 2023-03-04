//
//  ViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//
import CoreData
import UIKit

class MainViewController: UIViewController {
    
    //MARK: Properties
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
                button.addTarget(self, action: #selector(calendarButtonTapped(sender:)), for: .touchUpInside)
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
    
}

//MARK: Lifecycle methods
extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFirstTimeSetUp()
        
        reminderManager =  ReminderManager(sectionNames: sectionNames, comparators: comparators)
        reminderManager?.delegate = self
        do {
            try reminderManager!.prepareReminderStore()
        } catch {
            print(error.localizedDescription)
        }
        
        journalManager = JournalManager(managedObjectContext: managedContext, coreDataStack: coreDataStack)
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
}
    
//MARK: - Navigation
extension MainViewController {
    
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
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    @objc func presentReminderDetailView() {
        let reminder = Reminder()
        let vc = DetailViewController()
        vc.reminder = reminder
        vc.isAddingNewReminder = false
        vc.reminderManager = reminderManager
        
        present(vc, animated: true)
    }
}

//MARK: Selectors
extension MainViewController {
    
    @objc func calendarButtonTapped(sender: CalendarDayButton) {
        
        for button in dateButtonArray {
            button.isSelected = false
        }
        sender.isSelected = true
        
        selectedDate = sender.getDate()
        let results = journalManager?.getEntry(for: selectedDate)
        
        if let error = results?.error as? JournalManagerNSError, error == .noResultsRetrived {
            selectedDayLog = nil
        } else {
            selectedDayLog = results?.dayLogs.first
        }
        
        tableView.reloadData()
    }
    
    @objc func collapseExpandSection(sender: UIButton) {
        
        guard let tableView = self.tableView,
              let headerView = sender.superview?.superview as? HeaderView else { return }
        
        let sectionNumber: Int? = {
            for i in 0...tableView.numberOfSections {
                if tableView.headerView(forSection: i) == headerView {
                    return i
                }
            }
            return nil
        }()
        
        guard let sectionNumber = sectionNumber else { return }
        
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
}

//MARK: Initial setup
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
