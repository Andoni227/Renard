//
//  AboutAppVC.swift
//  Renard
//
//  Created by Andoni Suarez on 17/06/23.
//

import UIKit
import StoreKit

class AboutAppVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var options: [aboutUsObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.title = "Renard V \(version)"
        }
        
        options.append(aboutUsObject.init(section: "¿Para qué sirve Renard?", content: ["Renard pemite convertir las imagenes de tu galería a formato HEIF, reduciendo considerablemente el peso de la imagen sin compremeter la calidad y conservando todos sus metadatos (ubicación, fecha y hora, información de la cámara, parametros)."]))
        options.append(aboutUsObject.init(section: "¿Cómo se usa?", content: ["Selecciona una o varias fotos desde la vista de galería, da click en guardar y Renard convertirá las imaganes seleccionadas a HEIF, y las guardará en tu galería, después te dará la opción de eliminar la imagen original para evitar tener dos fotos iguales."]))
        options.append(aboutUsObject.init(section: "Borré una foto original y quiero recuperarla", content: ["No te preocupes, las fotos eliminadas por Renard se guardan en la carpeta de eliminados de tu galería, si lo necesitas desde ahí la puedes recuperar."]))
        options.append(aboutUsObject.init(section: "¿Por qué no se muestran todas mis fotos?", content: ["Las imagenes HEIF ya tienen una compresión lo suficientemente eficiente como para reducir aún más su peso. Por esa razón no se muestran en la app"]))
        options.append(aboutUsObject.init(section: "¿Mis datos están seguros?", content: ["Renard no recopila ningún tipo de dato, ni siquiera con fines estadisticos."]))
        options.append(aboutUsObject.init(section: "", content: ["Valorar Renard ⭐️⭐️⭐️⭐️⭐️"], tag: 5))
        options.append(aboutUsObject.init(section: "", content: ["Renard utiliza recursos de diversos artistas: ", "Cảnh Ngô - LottieFiles ↗️","Solitudinem - LottieFiles ↗️"], tag: 5))
        options.append(aboutUsObject.init(section: "", content: ["Contacto ↗️"], tag: 5))
        options.append(aboutUsObject.init(section: "", content: ["Politica de privacidad ↗️"], tag: 5))
        
        table.alwaysBounceVertical = false
        
        table.backgroundColor = UIColor.renardBoldBlue()
        table.delegate = self
        table.dataSource = self
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBackgroundHeavy()
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
        case "Valorar Renard ⭐️⭐️⭐️⭐️⭐️":
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        case "Contacto ↗️":
            if let url = URL(string: "https://www.renardapp.dev") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case "Politica de privacidad ↗️":
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
