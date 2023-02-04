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
    
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    var journalManager: JournalManager?
    var selectedDayLog: DayLog?
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
                    button.addTarget(self, action: #selector(setSelected(sender:)), for: .touchUpInside)
                    return button
            }()
                tempArray.append(button)
        }
        return tempArray
    }()
    
    //MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        performFirstTimeSetUp()
        journalManager = JournalManager(managedObjectContext: managedContext, coreDataStack: coreDataStack)
        
        let results = journalManager?.getEntry(for: Date())
        
        if let error = results?.error as? JournalManagerNSError, error == .noResultsRetrived {
            selectedDayLog = journalManager?.addEntry(Date())
        } else {
            selectedDayLog = results?.dayLogs.first
        }

        layoutUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
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
    
    @objc func setSelected(sender: UIButton) {
        
        for button in dateButtonArray {
            button.isSelected = false
        }
        sender.isSelected = true
        let date = (sender as! CalendarDayButton).getDate()
        let results = journalManager?.getEntry(for: date)
        
        if let error = results?.error as? JournalManagerNSError, error == .noResultsRetrived {
            selectedDayLog = journalManager?.addEntry(date)
        } else {
            selectedDayLog = results?.dayLogs.first
        }
        tableView.reloadData()
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
                targetVC.isShowingPhoto = true
                targetVC.dayLog = dayLog
                targetVC.managedContext = managedContext
                targetVC.journalManager = journalManager
                targetVC.strategy = .isCreatingNewEntry
            }
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var result: CGFloat = tableView.frame.height / 8
        if indexPath.row == 0 && selectedDayLog?.photo != nil {
            result = 5 * tableView.frame.height / 8
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return K.actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0, let data = selectedDayLog?.photo  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
            cell.delegate = self
            cell.myImageView.image = UIImage(data: data)
            cell.cornerRadius = 20
            cell.selectionStyle = .none
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.configureCell(with: K.actions[indexPath.row])
            cell.selectionStyle = .none
            cell.cornerRadius = 20
            return cell
            
        }
    }
    
    fileprivate func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentPhotoPicker()
        case 1:
            let sender = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: K.SegueIdentifiers.toQuestionVC, sender: sender)
        default:
            print("Add reminders cell tapped!")
        }
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let data = image.jpegData(compressionQuality: 1.0),
                    let log = selectedDayLog,
                  let manager = journalManager else { return }
            manager.addPhoto(jpegData: data, to: log)
        }
        tableView.reloadData()
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
}

extension MainViewController: PhotoCellDelegate {
    func leftButtonTapped() {
        presentPhotoPicker()
    }
    func rightButtonTapped() {
        guard let entry = selectedDayLog, let _journalManager = journalManager else { return }
        _journalManager.deletePhoto(entry: entry)
        tableView.reloadData()
    }
}
