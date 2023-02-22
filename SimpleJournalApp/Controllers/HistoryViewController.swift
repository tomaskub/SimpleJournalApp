//
//  HistoryViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//
import CoreData
import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    var journalManager: JournalManager?
    
    var dayLogs: [DayLog] = []
    var asyncFetchRequest: NSAsynchronousFetchRequest<DayLog>?
    let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        journalManager = JournalManager(managedObjectContext: managedContext, coreDataStack: coreDataStack)
        
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.frame.width / 20
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 115
        tableView.delegate = self
        tableView.dataSource = self
        //Old approach
//        fetchAllDayLogs()
        //New Approach
        _ = journalManager?.getAllEntriesAsync(completionHandler: {
            result in
            guard let finalResults = result.finalResult else { return }
            self.dayLogs = finalResults
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(notification:)), name: didSaveNotification, object: nil)
    }
    
    @objc func didSave(notification: Notification) {
        //old approach
//        fetchAllDayLogs()
        //new approach
        _ = journalManager?.getAllEntriesAsync(completionHandler: {
            result in
            guard let finalResults = result.finalResult else { return }
            self.dayLogs = finalResults
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    
    //MARK: - CoreData
    func fetchAllDayLogs() {
        let request = DayLog.fetchRequest() as NSFetchRequest<DayLog>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        asyncFetchRequest = NSAsynchronousFetchRequest<DayLog>(fetchRequest: request) {
            [unowned self] (result: NSAsynchronousFetchResult) in
            guard let dayLogs = result.finalResult else {
                return
            }
            self.dayLogs = dayLogs
            self.tableView.reloadData()
        }
        do {
            guard let asyncFetchRequest = asyncFetchRequest else { return }
            try managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntryViewController", let cell = sender as? HistoryTableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                let targetVC = segue.destination as! EntryViewController
                targetVC.managedContext = managedContext
                targetVC.dayLog = dayLogs[indexPath.row]
                targetVC.strategy = .isShowingOldEntry
                targetVC.journalManager = journalManager
            }
        }
    }
    
}
//MARK: tableView delegate and datasource methods
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        if let date = dayLogs[indexPath.row].date {
            if let answers = dayLogs[indexPath.row].answers?.allObjects as? [Answer] {
                
                let dateString = date.formatted(date: .abbreviated, time: .omitted)
                var hasSummary = false
                
                for answer in answers {
                    
                    if answer.question == Question.summary {
                        if let unwrappedText = answer.text {
                            cell.configureCell(date: dateString, summary: unwrappedText)
                        } else {
                            cell.configureCell(date: dateString)
                        }
                        cell.layoutIfNeeded()
                        hasSummary = true
                    }
                }
                
                if hasSummary == false {
                    cell.configureCell(date: dateString)
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "toHistoryDetailViewController", sender: tableView.cellForRow(at: indexPath))
        performSegue(withIdentifier: "toEntryViewController", sender: tableView.cellForRow(at: indexPath))
    }
}
