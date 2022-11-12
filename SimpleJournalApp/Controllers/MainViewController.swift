//
//  ViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let questions: [String] = [
        "Summary of the day",
        "What did i do good?",
        "What did i do bad?",
        "How can I improve on that?",
        "Where was my discipline and self-control tested?"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
        cell.textLabel?.textColor = .black
            cell.textLabel?.text = questions[indexPath.row]
        
        return cell
    }
    

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var journalStartButton: UIButton!
    var dateButtonArray: [UIButton] = {
        var tempArray: [UIButton] = []
        for i in 0...13 {
            let button: UIButton = {
                let button = UIButton()
                let date = Calendar.current.date(byAdding: .day, value: -7+i, to: Date.now)
                button.setTitle(String(date!.formatted(date: .complete, time: .omitted).prefix(3)), for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                if i == 7 {
                    button.backgroundColor = .black
                } else {
                    button.backgroundColor = .darkGray
                }
                return button
            }()
            tempArray.append(button)
            
        }
        return tempArray
    }()
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        journalStartButton.titleLabel?.text = "Answer tha questions!"
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted)
        for i in 0...dateButtonArray.count-1 {
            scrollViewContentView.addSubview(dateButtonArray[i])
            dateButtonArray[i].topAnchor.constraint(equalTo: scrollViewContentView.topAnchor).isActive = true
            dateButtonArray[i].bottomAnchor.constraint(equalTo: scrollViewContentView.bottomAnchor).isActive = true
            switch i {
            case 0:
                dateButtonArray[i].leadingAnchor.constraint(equalTo: scrollViewContentView.leadingAnchor, constant: 10).isActive = true
            default:
                dateButtonArray[i].leadingAnchor.constraint(equalTo: dateButtonArray[i-1].trailingAnchor, constant: 10).isActive = true
            }
            
            dateButtonArray[i].widthAnchor.constraint(equalToConstant: 50).isActive = true
            
        }
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
//        scrollViewContentView.trailingAnchor.constraint(equalTo: dateButtonArray.last!.trailingAnchor).isActive = true
        dateButtonArray.last!.trailingAnchor.constraint(equalTo: scrollViewContentView.trailingAnchor).isActive = true
        // Do any additional setup after loading the view.
    }
    @IBAction func journalStartButtonTapped(_ sender: Any) {

        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted)
    }
    

}

