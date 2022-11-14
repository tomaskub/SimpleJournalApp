//
//  ViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //placeholder questions
    let questions: [String] = [
        "Summary of the day",
        "What did i do good?",
        "What did i do bad?",
        "How can I improve on that?",
        "Where was my discipline and self-control tested?"]
    
    //tableView method implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        cell.configureCell(questionText: questions[indexPath.row])
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    //Calendar buttons
    var dateButtonArray: [CalendarDayButton] = {
        var tempArray: [CalendarDayButton] = []
            for i in 0...13 {
                let button: CalendarDayButton = {
                    let button = CalendarDayButton()
                    let date = Calendar.current.date(byAdding: .day, value: -7+i, to: Date.now)
                    // set the label text on the buttons
                    button.setTopLabelText(text: //String(date!.formatted(date: .abbreviated, time: .omitted).prefix(2)))
                                           String(Calendar.current.dateComponents([.day], from: date!).day!))
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
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted)
        // TODO: set up calendar button constraints to work properly with scrollView
        // set up constraints for calendar buttons
            for i in 0...dateButtonArray.count-1 {
                scrollView.addSubview(dateButtonArray[i])
                
                dateButtonArray[i].topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
                dateButtonArray[i].bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
                
                switch i {
                case 0:
                    dateButtonArray[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
                default:
                    dateButtonArray[i].leadingAnchor.constraint(equalTo: dateButtonArray[i-1].trailingAnchor, constant: 10).isActive = true
                }
                
                dateButtonArray[i].widthAnchor.constraint(equalToConstant: 85).isActive = true
                dateButtonArray[i].heightAnchor.constraint(equalToConstant: 100).isActive = true
//                dateButtonArray[i].widthAnchor.constraint(equalTo: dateButtonArray[i].heightAnchor, multiplier: 0.85).isActive = true
                
            }
        dateButtonArray.last?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 10).isActive = true
        // set up table view
        
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.bounds.width / 10
        
        
//        tableView.rowHeight = UITableView.automaticDimension
        
        //Note - make the automatic table view height work!
        tableView.rowHeight = tableView.frame.height / 7
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
        tableView.reloadData()
    }

    
    
}

