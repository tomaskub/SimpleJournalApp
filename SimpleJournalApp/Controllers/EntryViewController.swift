//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//
import CoreData
import UIKit

class EntryViewController: UIViewController {
    
    enum Strategy {
    case isShowingOldEntry
    case isCreatingNewEntry
    }
    var isShowingPhoto = false
    //  Constraint with constant to adjust based on keyboard height
    fileprivate var viewBottomConstraint: NSLayoutConstraint?
    fileprivate var qViewHeightConstraint: [NSLayoutConstraint] = []
    
    var journalManager: JournalManager!
    var managedContext: NSManagedObjectContext!
    var strategy: Strategy = .isCreatingNewEntry
    
    var lastTrailingConstraint: NSLayoutConstraint?
    
    var dayLog: DayLog? {
        didSet {
            guard let unwrappedDayLog = dayLog else {
                print("failed to unwrap day log passed to entryViewController by \(String(describing: self.parent))")
                return
            }
            if unwrappedDayLog.answers?.allObjects == nil {
                for question in Question.allCases {
                    let answer = Answer()
                    answer.question = question
                    answer.dayLog = unwrappedDayLog
                }
                populate(unwrappedDayLog.answers?.allObjects as! [Answer])
            } else {
                
                let answers = unwrappedDayLog.answers?.allObjects as! [Answer]
                populate(answers)
            }
            if let data = unwrappedDayLog.photo, let image = UIImage(data: data) {
                isShowingPhoto = true
                photoView.setImage(image)
            }
        }
        
    }
    
    
    
    //  MARK: UI elements declarations
    private let questionViews: [QuestionView] = {
        var views: [QuestionView] = []
        for question in Question.allCases {
            let view = QuestionView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            views.append(view)
        }
        return views
    }()
    
    private let photoView: PhotoView = {
        let view = PhotoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return view
    }()
    
    //MARK: button actions
    @objc func editPressed() {
        //Edit apperance of questionViews to show editable behaviour
        for view in questionViews {
            view.textView.isEditable = true
            view.textView.layer.borderColor = UIColor(named: K.Colors.complement)?.cgColor
            view.textView.layer.borderWidth = 3
            view.textView.layer.cornerRadius = 5
        }
        //Add photoview if edit button is pressed and photoView was not shown before
        if !isShowingPhoto {
            scrollView.addSubview(photoView)
            qViewHeightConstraint = []
            isShowingPhoto = true
            photoView.centerButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            if let qView = questionViews.last, let constraint = lastTrailingConstraint {
                let i = questionViews.count - 1
                constraint.isActive = false
                lastTrailingConstraint = photoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                NSLayoutConstraint.activate([
                                        photoView.heightAnchor.constraint(equalToConstant: view.frame.height),
                                        photoView.widthAnchor.constraint(equalToConstant: view.frame.width),
                                        qView.leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor),
                                        qView.trailingAnchor.constraint(equalTo: photoView.leadingAnchor),
                                        lastTrailingConstraint!
                                    ])
               
                
            }
            
        }
        
    }
    
    //  MARK: View life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        
        addSubviews()
        layoutUI()
        
        scrollView.delegate = self
        
        for view in questionViews {
            switch strategy {
            case .isCreatingNewEntry:
                view.textView.isEditable = true
                view.editButton.removeFromSuperview()
            case .isShowingOldEntry:
                view.textView.isEditable = false
                view.editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
            }
            view.textView.delegate = self
        }
        
        if isShowingPhoto {
            photoView.centerButton.removeFromSuperview()
            photoView.rightButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            photoView.leftButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        } else {
            photoView.leftButton.removeFromSuperview()
            photoView.rightButton.removeFromSuperview()
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDissapear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let log = dayLog {
            for view in questionViews {
                journalManager.addAnswer(to: log, for: view.question ?? .summary, text: view.returnAnswer())
            }
        }
        
    }
    
    
    //  MARK: Selectors
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            viewBottomConstraint?.constant = -(keyboardHeight+10)
            for constraint in qViewHeightConstraint {
                constraint.constant = -(keyboardHeight+10)
            }
        }
    }
    
    @objc func keyboardWillDissapear(_ notification: Notification) {
        viewBottomConstraint?.constant = -30
        for constraint in qViewHeightConstraint {
            constraint.constant = 0
        }
    }
    
    @objc func changeButtonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    @objc func deleteButtonTapped() {
        
        journalManager.deletePhoto(entry: dayLog!)
        photoView.setImage(nil)
        photoView.leftButton.removeFromSuperview()
        photoView.rightButton.removeFromSuperview()
        photoView.addSubview(photoView.centerButton)
        photoView.centerButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc func addButtonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
        photoView.centerButton.removeFromSuperview()
        photoView.addSubview(photoView.rightButton)
        photoView.rightButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        photoView.addSubview(photoView.leftButton)
        photoView.leftButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
    }
    //  MARK: UI layout methods
    func addSubviews(){
        view.addSubview(scrollView)
        for view in questionViews {
            scrollView.addSubview(view)
        }
        if isShowingPhoto {
            scrollView.addSubview(photoView)
        }
    }
    
    func layoutUI() {
        
        viewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        viewBottomConstraint?.isActive = true
        
        for (i, qview) in questionViews.enumerated() {
            qViewHeightConstraint.append(qview.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor))
            
            NSLayoutConstraint.activate([
                qViewHeightConstraint[i],
                qview.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)])
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        for i in 0...questionViews.count - 1 {
            if i == 0{
                questionViews[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            } else if i == questionViews.count - 1 {
                
                if isShowingPhoto {
                    lastTrailingConstraint = photoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                    NSLayoutConstraint.activate([
                        photoView.heightAnchor.constraint(equalToConstant: view.frame.height),
                        photoView.widthAnchor.constraint(equalToConstant: view.frame.width),
                        questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor),
                        questionViews[i].trailingAnchor.constraint(equalTo: photoView.leadingAnchor),
                        lastTrailingConstraint!
                    ])
                } else {
                    lastTrailingConstraint = questionViews[i].trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                    questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor).isActive = true
                    lastTrailingConstraint?.isActive = true
                }
                
            } else {
                questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor).isActive = true
            }
        }
        
        
    }

    func populate(_ answers: [Answer]) {
        
        for (i, questionString) in Question.allCases.enumerated() {
            questionViews[i].question = questionString
            questionViews[i].textView.text = answers.first(where: { $0.question == questionString })?.text
        }
    }
}

//MARK: UITextViewDelegate
extension EntryViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension EntryViewController: UIScrollViewDelegate {
    //used to switch responders for keyboard
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for view in questionViews {
            if CGRectIntersectsRect(scrollView.bounds, view.frame) {
                view.textView.becomeFirstResponder()
            }
        }
    }
}

extension EntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let data = image.jpegData(compressionQuality: 1.0),
                    let log = dayLog,
                  let manager = journalManager else { return }
            manager.addPhoto(jpegData: data, to: log)
            photoView.setImage(image)
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
}
