//
//  AboutAppVC.swift
//  Renard
//
//  Created by Andoni Suarez on 17/06/23.
//

import UIKit
import StoreKit

class AboutAppVC: UIViewController {
    
    @IBOutlet weak var configIcon: UIBarButtonItem!
    @IBOutlet weak var table: UITableView!
    
    var options: [aboutUsObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setTable()
    }
    
    func configureView(){
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.title = "Renard V \(version)"
        }
        
        table.alwaysBounceVertical = false
        table.backgroundColor = UIColor.renardBoldBlue()
        table.delegate = self
        table.dataSource = self
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBackgroundHeavy()
        
        if #available(iOS 17.0, *) {
            configIcon.image = UIImage(systemName: "gauge.with.dots.needle.67percent")
        }else{
            configIcon.image = UIImage(systemName: "speedometer")
        }
    }
    
    func setTable(){
        options.append(aboutUsObject.init(section: NSLocalizedString("InfoScreen1Title", comment: ""), content: [NSLocalizedString("InfoScreen1Subtitle", comment: "")]))
        options.append(aboutUsObject.init(section: NSLocalizedString("InfoScreen2Title", comment: ""), content: [NSLocalizedString("InfoScreen2Subtitle", comment: "")]))
        options.append(aboutUsObject.init(section: NSLocalizedString("InfoScreen3Title", comment: ""), content: [NSLocalizedString("InfoScreen3Subtitle", comment: "")]))
        options.append(aboutUsObject.init(section: NSLocalizedString("InfoScreen4Title", comment: ""), content: [NSLocalizedString("InfoScreen4Subtitle", comment: "")]))
        options.append(aboutUsObject.init(section: NSLocalizedString("InfoScreen5Title", comment: ""), content: [NSLocalizedString("InfoScreen5Subtitle", comment: "")]))
        options.append(aboutUsObject.init(section: "", content: [NSLocalizedString("InfoScreen6Subtitle", comment: "")], tag: 5))
        
        options.append(aboutUsObject.init(section: "", content: [NSLocalizedString("InfoScreen7Subtitle", comment: ""), "Cảnh Ngô - LottieFiles ↗️","Solitudinem - LottieFiles ↗️"], tag: 5))
        options.append(aboutUsObject.init(section: "", content: [NSLocalizedString("InfoScreen8Subtitle", comment: "")], tag: 5))
        options.append(aboutUsObject.init(section: "", content: [NSLocalizedString("InfoScreen9Subtitle", comment: "")], tag: 5))
    }
    
    @IBAction func openStatistics(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "StatisticsVC") as? StatisticsVC {
            present(viewController, animated: true, completion: nil)
        }
    }
}

extension AboutAppVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.width, height: 30))
        view.backgroundColor =  UIColor.renardBoldBlue()
        
        let lbl = UILabel(frame: CGRect(x: 15, y: -10, width: view.frame.width - 15, height: 30))
        lbl.numberOfLines = 0
        lbl.font = UIFont.montserratBold(ofSize: 13.0)
        lbl.text = options[section].section
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return options[section].section
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let customSize = options[section].tag{
            return customSize
        }else{
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.renardDarkBlue()
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.montserratMedium(ofSize: 13.0)
        cell.textLabel?.text = options[indexPath.section].content[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = options[indexPath.section].content[indexPath.row]
        switch text{
        case "Cảnh Ngô - LottieFiles ↗️":
            if let url = URL(string: "https://lottiefiles.com/canhngo") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case "Solitudinem - LottieFiles ↗️":
            if let url = URL(string: "https://lottiefiles.com/solitudinem") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case NSLocalizedString("InfoScreen6Subtitle", comment: ""):
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        case NSLocalizedString("InfoScreen8Subtitle", comment: ""):
            if let url = URL(string: "https://www.renardapp.dev") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case NSLocalizedString("InfoScreen9Subtitle", comment: ""):
            if let url = URL(string: "https://www.renardapp.dev/politica-de-privacidad") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        default:
            ()
        }
    }
}
