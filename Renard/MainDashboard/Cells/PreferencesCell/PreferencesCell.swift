//
//  PreferencesCell.swift
//  Renard
//
//  Created by Andoni Suarez on 16/03/24.
//

import UIKit

class PreferencesCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var swtch: UISwitch!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var switchView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setCellColor(_ color: UIColor){
        self.backgroundColor = color
        containerView.backgroundColor = color
        switchView.backgroundColor = color
    }
    
}
