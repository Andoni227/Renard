//
//  StatisticsTableViewCell.swift
//  Renard
//
//  Created by Andoni Suarez on 27/06/23.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel! 

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.renardDarkBlue()
        firstLabel.textColor = .white
        secondLabel.textColor = .white
        firstLabel.font = UIFont.montserratRegular(ofSize: 15.0)
        secondLabel.font = UIFont.montserratRegular(ofSize: 15.0)
    }
}
