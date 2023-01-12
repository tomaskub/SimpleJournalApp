//
//  ViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//
import CoreData
import UIKit

class MainViewController: UIViewController {
    
    //TODO: Create a custom view for this controller?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    //Declare calendar buttons
    let dateButtonArray: [CalendarDayButton] = {
        
        var tempArray: [CalendarDayButton] = []
            
        for i in 0...13 {
                let button: CalendarDayButton = {
                    let date = Calendar.current.date(byAdding: .day, value: -7+i, to: Date.now)
                    let button = CalendarDayButton(date: date!)//, isToday: false)
                    if i == 7 {
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
    let actions = ["Add photo!", "Journal", "Add reminders for next day"]
    
    var selectedDayLogDate = Date()
    var selectedDayLog: DayLog?
    //MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        performFirstTimeSetUp()
        
        fetchDayLog(for: selectedDayLogDate)

        layoutUI()
        
        tableView.rowHeight = tableView.frame.height / 7
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setContentOffset(CGPoint(x: 5 * 105 , y: 0 ), animated: true)
        if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.useDarkTheme) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
    @objc func setSelected(sender: UIButton) {
        
        for button in dateButtonArray {
            button.isSelected = false
        }
        sender.isSelected = true
        selectedDayLogDate = (sender as! CalendarDayButton).getDate()
        
        
    }
    
//    MARK: UI layout
    func layoutUI(){
        //adjust tableview appearance
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.bounds.width / 10
        // configure date label text
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        // TODO: set up calendar button constraints to work properly with scrollView - still has
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
            }
            targetVC.delegate = self
        }
    }
}

//MARK: QuestionCellDelegate methods
extension MainViewController: QuestionCellDelegate {
    func buttonPressed(sender: QuestionCell) {
        fetchDayLog(for: selectedDayLogDate)
            performSegue(withIdentifier: K.SegueIdentifiers.toQuestionVC, sender: sender)
        
        
    }
}

//MARK: CoreData methods
extension MainViewController {
    
    func fetchDayLog(for date: Date) {
        //Create request
        let request = DayLog.fetchRequest() as NSFetchRequest<DayLog>
        //Create dates for begining of the day and end of a day
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)
        //Create sub predicates and compond predicate
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        //add predicate to the request
        request.predicate = datePredicate
        //Retrive day log for that date
        do {
            let retrivedDayLogs = try context.fetch(request)
            if retrivedDayLogs.isEmpty {
                print("There is no logs for current day, creating a new DayLog")
                //If there is no retrived day logs for particular day, create an empty day log
                selectedDayLog = createNewDayLog()
            } else if retrivedDayLogs.count > 1 {
                print("Retrived multiple day logs = \(retrivedDayLogs.count) - this should not be possible, something is wrong")
                selectedDayLog = retrivedDayLogs.first!
            } else {
                print("Retrived 1 day log succesfully")
                selectedDayLog = retrivedDayLogs.first!
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createNewDayLog() -> DayLog {
        let newDayLog = DayLog(context: self.context)
        
        newDayLog.date = Calendar.current.startOfDay(for: selectedDayLogDate)
        newDayLog.id = UUID()
        
        do {
            try self.context.save()
        } catch {
            print(error)
        }
        
        return newDayLog
        
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
    //tableView method implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        cell.configureCell(questionText: actions[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: QuestionViewControllerDelegate methods
extension MainViewController: QuestionViewControllerDelegate {
    func saveDayLog(dayLog: DayLog) {
        
        print(dayLog.description)
        selectedDayLog = dayLog
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
