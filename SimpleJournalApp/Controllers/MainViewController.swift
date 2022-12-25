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
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    //Declare calendar buttons
    var dateButtonArray: [CalendarDayButton] = {
        var tempArray: [CalendarDayButton] = []
            for i in 0...13 {
                let button: CalendarDayButton = {
                    let button = CalendarDayButton()
                    let date = Calendar.current.date(byAdding: .day, value: -7+i, to: Date.now)
                    // set the label text on the buttons
                    button.setTopLabelText(text:String(Calendar.current.dateComponents([.day], from: date!).day!))
                    button.setBottomLabelText(text: String(date!.formatted(date: .complete, time: .omitted).prefix(3).uppercased()))
                    // change color on current day button
                    if i == 7 {
                        button.primaryColor = .black
                    }
                    button.translatesAutoresizingMaskIntoConstraints = false
                    return button
            }()
                tempArray.append(button)
        }
        return tempArray
    }()
    
    var items: [DayLog]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDayLogs()
        
        
        
        performFirstTimeSetUp()
        configureView()
        // set up table view apperance
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.bounds.width / 10
        
        //TODO: - make the automatic table view height work!
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
    
    func configureView(){
        // configure date label text
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted)
        // TODO: set up calendar button constraints to work properly with scrollView - still has
        // set up constraints for calendar buttons
        for i in 0...dateButtonArray.count-1 {
            scrollView.addSubview(dateButtonArray[i])
            switch i {
            case 0:
                dateButtonArray[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
            default:
                dateButtonArray[i].leadingAnchor.constraint(equalTo: dateButtonArray[i-1].trailingAnchor, constant: 10).isActive = true
            }
            dateButtonArray[i].topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            dateButtonArray[i].bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            dateButtonArray[i].widthAnchor.constraint(equalToConstant: scrollView.frame.height * 0.85).isActive = true
            dateButtonArray[i].heightAnchor.constraint(equalToConstant: scrollView.frame.height).isActive = true
        }
    dateButtonArray.last?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 10).isActive = true
    }
    
    //MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueIdentifiers.toQuestionVC, let cell = sender as? QuestionCell{
            let targetVC = segue.destination as! QuestionViewController
            if let indexPath = tableView.indexPath(for: cell) {
                let question = K.questions[indexPath.row]
                targetVC.setLabelText(text: question)
                targetVC.delegate = self
            } else {
                print("Error getting question text")
            }
        }
    }
}

//MARK: QuestionCellDelegate methods
extension MainViewController: QuestionCellDelegate {
    func buttonPressed(sender: QuestionCell) {
        if let indexPath = tableView.indexPath(for: sender){
            let question = K.questions[indexPath.row]
            print("Question button pressed for: \(question)")
            performSegue(withIdentifier: K.SegueIdentifiers.toQuestionVC, sender: sender)
        }
        
    }
}

//MARK: CoreData methods
extension MainViewController {
    
    func fetchDayLogs() {
        do {
            try self.items = context.fetch(DayLog.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createNewDayLog() {
        let newDayLog = DayLog(context: self.context)
        
        newDayLog.date = Date()
        newDayLog.id = UUID()
        newDayLog.answers = []
        
        do {
            try self.context.save()
        } catch {
            print(error)
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
                    if setting.key != K.UserDefaultsKeys.isTrackDataEnabled && setting.key != K.UserDefaultsKeys.sendFailureReports {
                        defaults.set(false, forKey: setting.key)
                        print("Setting set to false for key \(setting.key)")
                    } else {
                        defaults.set(true, forKey: setting.key)
                        print("Setting set to true for \(setting.key)")
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
        return K.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        cell.configureCell(questionText: K.questions[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//MARK: QuestionViewControllerDelegate methods
extension MainViewController: QuestionViewControllerDelegate {
    func nextButtonPressed(question: String, Answer: String) {
        print(question)
        print(Answer)
    }
    
    func backButtonPressed(question: String, Answer: String) {
        print(question)
        print(Answer)
    }
    
}
