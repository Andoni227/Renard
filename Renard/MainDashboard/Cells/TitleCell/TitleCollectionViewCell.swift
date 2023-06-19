//
//  TitleCollectionViewCell.swift
//  Renard
//
//  Created by Andoni Suarez on 13/06/23.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var container: UIView! 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.montserratMedium(ofSize: 13.0)
        self.container.layer.cornerRadius = 10.0
        self.container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setSelectedStyle(){
        self.container.clipsToBounds = true
        self.container.backgroundColor = UIColor.renardBackgroundHeavy()
        self.lblTitle.textColor = .white
    }
    
    func setUnselectedStyle(){
        self.container.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.lblTitle.textColor = .black
    }
}
