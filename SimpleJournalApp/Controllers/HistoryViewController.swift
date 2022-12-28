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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let results = fetchAllDayLogs() {
            dayLogs = results
            tableView.reloadData()
        }
        
    }
    
    //MARK: - CoreData
    func fetchAllDayLogs() -> [DayLog]? {
        let request = DayLog.fetchRequest() as NSFetchRequest<DayLog>
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Prototype", for: indexPath)
        
        
        if let date = dayLogs[indexPath.row].date {
            cell.textLabel?.text = date.formatted(date: .complete, time: .omitted)
        }
        
        if let answers = dayLogs[indexPath.row].answers?.allObjects as? [Answer] {
            for answer in answers {
                if answer.question == K.questions[0] {
                    cell.detailTextLabel?.text = answer.text
                }
            }
        } else {
            cell.detailTextLabel?.text = " There was no summary for this day saved."
        }
        
        return cell
    }
    
    
}
