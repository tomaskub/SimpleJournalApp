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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    var dayLogs: [DayLog] = []
    
    let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        tableView.layer.cornerRadius = tableView.layer.frame.width / 20
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 115
        tableView.delegate = self
        tableView.dataSource = self
        
        if let results = fetchAllDayLogs() {
            dayLogs = results
            tableView.reloadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(notification:)), name: didSaveNotification, object: nil)
    }
    
    @objc func didSave(notification: Notification) {
        if let results = fetchAllDayLogs() {
            dayLogs = results
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    
    //MARK: - CoreData
    func fetchAllDayLogs() -> [DayLog]? {
        let request = DayLog.fetchRequest() as NSFetchRequest<DayLog>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        var results: [DayLog]?
        do {
            results = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return results
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntryViewController", let cell = sender as? HistoryTableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                let targetVC = segue.destination as! EntryViewController
                targetVC.dayLog = dayLogs[indexPath.row]
                targetVC.strategy = .isShowingOldEntry
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
                    
                    if answer.question == K.questions[0] {
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
