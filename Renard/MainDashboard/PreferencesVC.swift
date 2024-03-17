//
//  PreferencesVC.swift
//  Renard
//
//  Created by Andoni Suarez on 16/03/24.
//

import UIKit

class PreferencesViewController: UIViewController{
    
    @IBOutlet weak var table: UITableView!

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
            cell?.lblTitle.text = NSLocalizedString("preferencesOption2", comment: "")
        default:
            cell?.switchView.isHidden = false
        }
        
        return cell ?? UITableViewCell()
    }
}
