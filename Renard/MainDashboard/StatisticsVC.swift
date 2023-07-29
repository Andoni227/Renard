//
//  StatisticsVC.swift
//  Renard
//
//  Created by Andoni Suarez on 23/06/23.
//

import UIKit
import Photos

class StatisticsVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var options: [aboutUsObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        self.title = NSLocalizedString("StatisticsScreenTitle", comment: "")
        
        options.append(aboutUsObject.init(section: NSLocalizedString("MaxResPhoto", comment: ""), content: [assetsLibrary.shared.maxResPhoto ?? "-"], tag: 1))
        options.append(aboutUsObject.init(section: NSLocalizedString("MinusResPhoto", comment: ""), content: [assetsLibrary.shared.lowResPhoto ?? "-"], tag: 2))
        options.append(aboutUsObject.init(section: NSLocalizedString("MostCommonFormat", comment: ""), content: [assetsLibrary.shared.mostCommonFormat?.getName ?? "-"]))
        options.append(aboutUsObject.init(section: NSLocalizedString("LessCommonFormat", comment: ""), content: [assetsLibrary.shared.lessCommonFormat?.getName ?? "-"]))
        options.append(aboutUsObject.init(section: NSLocalizedString("TotalPhotos", comment: ""), content: ["\(assetsLibrary.shared.photos.count)"]))
        for format in assetsLibrary.shared.dataTypes{
            options.append(aboutUsObject.init(section: "\(NSLocalizedString("PhotosFormatPrefix", comment: ""))\(format.imageType.getName)\(NSLocalizedString("PhotosFormatPostFix", comment: ""))", content: ["\(format.count)"]))
        }
     
        table.alwaysBounceVertical = false
        table.layer.cornerRadius = 15.0
        table.backgroundColor = UIColor.renardDarkBlue()
        table.delegate = self
        table.dataSource = self
        registerCells()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBackgroundHeavy()
    }
    
    func registerCells(){
        table.register(UINib(nibName: StatisticsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: StatisticsTableViewCell.identifier)
    }
    
    @IBAction func openStatistics(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "StatisticsVC") as? StatisticsVC {
            present(viewController, animated: true, completion: nil)
        }
    }
}

extension StatisticsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.identifier, for: indexPath) as! StatisticsTableViewCell
        cell.firstLabel.text = options[indexPath.row].section
        cell.secondLabel.text = options[indexPath.row].content.first
        cell.tag = Int(options[indexPath.row].tag ?? 0.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch table.cellForRow(at: indexPath)?.tag{
        case 1:
            if let vc = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewVC") as? ImagePreviewVC {
                vc.receivedAsset =  assetsLibrary.shared.maxResPhotoAsset
                self.present(vc, animated: true)
            }
        case 2:
            if let vc = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewVC") as? ImagePreviewVC {
                vc.receivedAsset =  assetsLibrary.shared.lowResPhotoAsset
                self.present(vc, animated: true)
            }
        case .none:
            ()
        case .some(_):
            ()
        }
    }
}

