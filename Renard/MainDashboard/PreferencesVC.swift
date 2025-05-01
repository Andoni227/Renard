//
//  PreferencesVC.swift
//  Renard
//
//  Created by Andoni Suarez on 16/03/24.
//

import UIKit
import CoreData

class PreferencesViewController: UIViewController{
    
    @IBOutlet weak var table: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        self.view.backgroundColor = .renardBackgroundHeavy()
        self.title = "\(NSLocalizedString("preferences", comment: ""))"
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBackgroundHeavy()
        setTable()
    }
    
    func setTable(){
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: PreferencesCell.identifier, bundle: nil), forCellReuseIdentifier: PreferencesCell.identifier)
        table.alwaysBounceVertical = false
    }
    
    func changeCompressionAlert(){
        let alert = UIAlertController(title: "Renard", message: NSLocalizedString("preferencesOption2", comment: ""), preferredStyle:  UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
        
        var levelCompression = -1
        for value in stride(from: 0.7, through: 0.9, by: 0.1) {
            levelCompression += 1
            let alertAction = UIAlertAction(title: NSLocalizedString("preferencesOption2_\(levelCompression)", comment: ""), style: .default, handler: {_ in
                if value == 0.0{
                    self.maxinumCompressionAlert()
                }else{
                    UserDefaults.standard.setValue(Double(String(format: "%.1f", value)), forKey: "compressionLevel")
                    self.table.reloadData()
                }
            })
            alert.addAction(alertAction)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
    
    func getCompression() -> String{
        let savedPreference = UserDefaults.standard.value(forKey: "compressionLevel") as? Double
        switch savedPreference{
        case 0.7:
            return NSLocalizedString("preferencesOption2_0", comment: "")
        case 0.8:
            return NSLocalizedString("preferencesOption2_1", comment: "")
        case 0.9:
            return NSLocalizedString("preferencesOption2_2", comment: "")
        case .none:
            return NSLocalizedString("preferencesOption2_1", comment: "")
        case .some(_):
            return NSLocalizedString("preferencesOption2_1", comment: "")
        }
    }
    
    func maxinumCompressionAlert(){
        let alert = UIAlertController(title: NSLocalizedString("attention", comment: ""), message: NSLocalizedString("preferencesOption2_6", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: {_ in
            UserDefaults.standard.setValue(0.0, forKey: "compressionLevel")
            self.table.reloadData()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc func switchChanged(_ sender: UISwitch){
        UserDefaults.standard.setValue(sender.isOn, forKey: "deleteByDefault")
    }
}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: PreferencesCell.identifier, for: indexPath) as? PreferencesCell
        
        cell?.lblTitle.font = UIFont.montserratMedium(ofSize: 15.0)
        cell?.setCellColor(UIColor.renardBoldBlue())
        cell?.lblTitle.textColor = UIColor.white
        
        switch indexPath.row{
        case 0:
            cell?.switchView.isHidden = false
            if let savedStatus = UserDefaults.standard.value(forKey: "deleteByDefault"){
                cell?.swtch.isOn = savedStatus as? Bool ?? true
            }
            cell?.swtch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell?.lblTitle.text = NSLocalizedString("preferencesOption1", comment: "")
        case 1:
            cell?.switchView.isHidden = true
            let compressionLevel = getCompression()
            cell?.lblTitle.text = "\(NSLocalizedString("preferencesOption2", comment: "")): \(compressionLevel)"
        default:
            cell?.switchView.isHidden = false
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            changeCompressionAlert()
        }
    }
}
