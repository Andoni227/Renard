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
    var savedSettings = [Preferences]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        self.view.backgroundColor = .renardBackgroundHeavy()
        self.title = "\(NSLocalizedString("preferences", comment: ""))"
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBackgroundHeavy()
        loadSettings()
        setTable()
    }
    
    func loadSettings(){
        let request: NSFetchRequest<Preferences> = Preferences.fetchRequest()
        
        do{
            savedSettings = try context.fetch(request)
        }catch{ () }
    }
    
    func setTable(){
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: PreferencesCell.identifier, bundle: nil), forCellReuseIdentifier: PreferencesCell.identifier)
        table.alwaysBounceVertical = false
    }
    
    func changeCompressionAlert(){
        let alert = UIAlertController(title: "Renard", message: NSLocalizedString("preferencesOption2", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("preferencesOption2_1", comment: ""), style: .default, handler: {_ in
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("preferencesOption2_2", comment: ""), style: .default, handler: {_ in
            self.maxinumCompressionAlert()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
    
    func maxinumCompressionAlert(){
        let alert = UIAlertController(title: NSLocalizedString("attention", comment: ""), message: NSLocalizedString("preferencesOption2_3", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: {_ in
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
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
            cell?.lblTitle.text = NSLocalizedString("preferencesOption1", comment: "")
        case 1:
            cell?.switchView.isHidden = true
            cell?.lblTitle.text = "\(NSLocalizedString("preferencesOption2", comment: "")): Normal"
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
