//
//  StringExtensions.swift
//  Renard
//
//  Created by Andoni Suarez on 12/06/23.
//

import UIKit

extension String{
    func stringToDate(format: String) -> Date{
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = format
        dateFormatterIn.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterIn.timeZone = TimeZone.current
        let dateIn = dateFormatterIn.date(from: self)
        return dateIn ?? Date()
    }
}

public extension UICollectionViewCell {
    class var identifier: String { return String(describing: self) }
}

extension UIButton{
    func makeRoundedWithShadow(){
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4
    }
}

public extension UIFont {
    class func montserratBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func montserratMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func montserratRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func montserratLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}


extension UIColor{
    class func renardBackgroundHeavy() -> UIColor{
       return UIColor(red: 9/255, green: 12/255, blue: 17/255, alpha: 1.0)
    }
    
    class func renardDarkBlue() -> UIColor{
        return UIColor(red: 48/255, green: 68/255, blue: 99/255, alpha: 1.0)
    }
    
    class func renardBoldBlue() -> UIColor{
       return UIColor(red: 91/255, green: 123/255, blue: 173/255, alpha: 1.0)
    }
}
