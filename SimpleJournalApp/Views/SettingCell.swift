//
//  SettingCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/19/22.
//

import UIKit

protocol SettingCellDelegate {
    func toggleSwitchPressed(sender: SettingCell)
    func chevronButtonPressed(sender: SettingCell)
    func timePickerEditingDidEnd(sender: SettingCell)
}

//TODO: fix UISwitch button and UIDatePicker targets not working properly (chevron works properly???)

@IBDesignable class SettingCell: UITableViewCell {
    
    enum CellButtonType {
        case withChevronRight
        case withToggleSwitch
        case withTimePicker
    }
    
    static let identifier = "SettingCell"
    
    var cellButtonType: CellButtonType
    var delegate: SettingCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Sample Setting"
        label.textColor = .black // UIColor(named: "ComplementColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.image = UIImage(systemName: "multiply.circle")
        return view
    }()
    private let button: UIButton = {
        let button = UIButton()
        //        button.setTitle("button", for: .normal)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(named: "DominantColor")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    private let cellContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cellButtonType = .withChevronRight
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Set up appearance of the cell
        
        //set up background color and corner radius
        cellContentView.layer.cornerRadius = contentView.frame.height * 0.5
        cellContentView.backgroundColor = UIColor(named: "ComplementColor")
        //set up shadow
        cellContentView.layer.shadowOffset = .zero
        cellContentView.layer.shadowColor = UIColor.black.cgColor
        cellContentView.layer.shadowRadius = 2.0
        cellContentView.layer.shadowOpacity = 0.5
        // set up constraints for cellContentView
        //Setup icon image
        icon.contentMode = .scaleAspectFit
        
        // add subviews
        contentView.addSubview(cellContentView)
        cellContentView.addSubview(label)
        cellContentView.addSubview(icon)
        //Build cell based on the cell type
        switch cellButtonType {
        case .withChevronRight:
            cellContentView.addSubview(button)
            setUpConstraints(first: icon, second: label, third: button)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        case .withToggleSwitch:
            cellContentView.addSubview(toggleSwitch)
            setUpConstraints(first: icon, second: label, third: toggleSwitch)
            toggleSwitch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        case .withTimePicker:
            cellContentView.addSubview(timePicker)
            setUpConstraints(first: icon, second: label, third: timePicker)
            timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: UIControl.Event.editingDidEndOnExit)
        }
    }
    
    @objc func buttonPressed() {
        delegate?.chevronButtonPressed(sender: self)
    }
    
    @objc func switchValueDidChange(){
        delegate?.toggleSwitchPressed(sender: self)
    }
    
    @objc func timePickerValueChanged(){
        delegate?.timePickerEditingDidEnd(sender: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func configureCell(iconSystemName: String, labelText: String, cellType: CellButtonType){//} , buttonImage: UIImage){
        
        label.text = labelText
        icon.image = UIImage(systemName: iconSystemName)
        
        if self.cellButtonType == cellType {
            //do nothing - button type is already good
        } else {
            //when cell button is not cell type remove the button that is present
            switch cellButtonType {
            case .withToggleSwitch:
                toggleSwitch.removeFromSuperview()
            case .withChevronRight:
                button.removeFromSuperview()
            case .withTimePicker:
                timePicker.removeFromSuperview()
            }
            // when cell button is not the cell type add the other button
            switch cellType {
            case .withChevronRight:
                cellContentView.addSubview(button)
                setUpConstraintsForThirdView(view: button)
            case .withToggleSwitch:
                cellContentView.addSubview(toggleSwitch)
                setUpConstraintsForThirdView(view: toggleSwitch)
                toggleSwitch.addTarget(self, action: #selector(switchValueDidChange), for: UIControl.Event.valueChanged)
            case .withTimePicker:
                cellContentView.addSubview(timePicker)
                setUpConstraintsForThirdView(view: timePicker)
                timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: UIControl.Event.valueChanged)
            }
            //set the cellButtonType to correct type
            cellButtonType = cellType
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpConstraints(first: UIView, second: UIView, third: UIView){
        //set up constraints for the container view
        cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant:  5).isActive = true
        cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        //set up constraints for first item
        first.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
        first.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10.0).isActive = true
        first.widthAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        first.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        // set up constraints for second item
        second.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
        second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: 10).isActive = true
        second.widthAnchor.constraint(equalToConstant: 150).isActive = true
        second.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10 ).isActive = true
        // set up constraints for third item
        setUpConstraintsForThirdView(view: third)
    }
    
    func setUpConstraintsForThirdView(view: UIView){
        view.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10).isActive = true
        if let _ = view as? UISwitch {
            return
        } else {
            view.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        }
        
        
    }
    
    /// Return the state of the UISwitch located in the cell
    public func getToggleButtonState() -> Bool? {
        if self.cellButtonType == .withToggleSwitch {
            return toggleSwitch.isOn
        } else {
            return nil
        }
    }
    
    public func setToggleButtonState(value: Bool) {
        toggleSwitch.setOn(value, animated: true)
        print("Switch set to \(value) for cell \(String(describing: self.label.text))")
    }
    
    public func getText() -> String? {
        return label.text
    }
    
    public func getTime() -> Date? {
        return timePicker.date
    }
    public func setTime(date: Date) {
        timePicker.setDate(date, animated: true)
    }
    
}
