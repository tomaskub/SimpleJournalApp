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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    var dayLogs: [DayLog] = []
    
    let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        if let date = dayLogs[indexPath.row].date {
            if let answers = dayLogs[indexPath.row].answers?.allObjects as? [Answer] {
                for answer in answers {
                    if answer.question == K.questions[0] {
                        cell.configureCell(date: date.formatted(date: .abbreviated, time: .omitted), summary: answer.text!)
                        cell.layoutIfNeeded()
                    }
                }
            }
        }
        return cell
    }
}
