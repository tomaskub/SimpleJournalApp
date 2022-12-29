//
//  HistoryDetailViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/29/22.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "This is HistoryDetailsViewController"
        label.translatesAutoresizingMaskIntoConstraints = false 
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        // Do any additional setup after loading the view.
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
