//
//  ViewController.swift
//  Renard
//
//  Created by Andoni Suarez on 11/06/23.
//

import UIKit
import Lottie
import Photos
import CoreData

class ImagePreviewVC: UIViewController{
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    // @IBOutlet weak var btnSaveMetadata: UIBarButtonItem!
    @IBOutlet weak var swtch: UISwitch!
    @IBOutlet weak var lblIndicator: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var swtchView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var receivedAsset: PHAsset?
    var selectedObject: ImageObject?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeView()
        loadAsset()
    }
    
    func customizeView(){
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.montserratMedium(ofSize: 15.0)
        ]
        btnSave.setTitleTextAttributes(attributes, for: .normal)
        //  btnSaveMetadata.setTitleTextAttributes(attributes, for: .normal)
        //  btnSaveMetadata.title = NSLocalizedString("saveMetadataBtn", comment: "")
        lblIndicator.text = NSLocalizedString("deleteAfterSaveOne", comment: "")
        lblIndicator.font = UIFont.montserratMedium(ofSize: 15.0)
        lblTitle.font = UIFont.montserratMedium(ofSize: 15.0)
        lblTitle.textColor = .white
        if let savedStatus = UserDefaults.standard.value(forKey: "deleteByDefault"){
            swtch.isOn = savedStatus as? Bool ?? true
        }
        self.swtchView.backgroundColor = UIColor.renardDarkBlue()
        self.view.backgroundColor = UIColor.renardBackgroundHeavy()
        self.navBar.backgroundColor = UIColor.renardDarkBlue()
    }
    
    func loadAsset(){
        DispatchQueue.main.async { [self] in
            btnSave.customView?.isUserInteractionEnabled = false
            btnShare.customView?.isUserInteractionEnabled = false
            showLoading(title: NSLocalizedString("downloading", comment: ""))
        }
        
        receivedAsset?.isLocalItem(completion: { [self] success in
            hideLoading(completion: { [self] in
                if success{
                    if let asset = receivedAsset{
                        asset.toImageObject(completion: { [self] object in
                            DispatchQueue.main.async { [self] in
                                btnSave.customView?.isUserInteractionEnabled = true
                                btnShare.customView?.isUserInteractionEnabled = true
                                imgView.image = object.image
                                selectedObject = object
                            }
                            
                            if receivedAsset?.getType() == .HEIC{
                                btnSave.isEnabled = false
                                btnShare.isEnabled = false
                            }
                        })
                    }
                }else{
                    DispatchQueue.main.async {
                        self.btnSave.isEnabled = false
                        self.btnShare.isEnabled = false
                        self.showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("downloadFailed", comment: ""), buttonText: NSLocalizedString("retry", comment: ""), handler: {_ in
                            self.dismiss(animated: true)
                        })
                    }
                }
            })
        })
    }
    
    func convertAndSaveInCameraRoll(){
        if let receivedAsset = receivedAsset{
            showLoading()
            convertAndSaveAssetAsHEIF(from: receivedAsset, completion: { success, error in
                self.hideLoading {
                    self.showAlertWithLottie(lottie: .FoxSuccess, labelText: NSLocalizedString("saveSuccess", comment: ""), buttonText: NSLocalizedString("accept", comment: ""), handler: { _ in
                        if self.swtch.isOn{
                            if let asset = self.receivedAsset{
                                self.delete(assets: [asset])
                            }
                        }else{
                            self.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: Notification.Name("updateLibrary"), object: nil)
                            })
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    @IBAction func exportImage(_ sender: UIButton){
        showLoading()
        
        if var ciImage = CIImage(image: selectedObject?.image ?? UIImage()){
            
            if let photoMetaData = selectedObject?.metadata{
                ciImage = addMetadataToCIImage(ciImage: ciImage, metadata: photoMetaData)
            }
            
            if let dateTime = selectedObject?.dateTime{
                ciImage = addCustomDateTimeToCIImage(ciImage: ciImage, dateTime: dateTime)
            }
            
            ciImage.toHEIFData(HEIFData: { data in
                let activityViewController = UIActivityViewController(activityItems: [data!], applicationActivities: nil)
                self.hideLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                        self.present(activityViewController, animated: true, completion: nil)
                    })
                }
            })
        }
        
    }
    
    @IBAction func saveToCameraRoll(_ sender: UIButton){
        if receivedAsset?.getType() == .AVIF{
            let alert = UIAlertController(title: "Renard", message: NSLocalizedString("saveAVIFAlert", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: { [self]_ in
                convertAndSaveInCameraRoll()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
            self.present(alert, animated: true)
        }else{
            convertAndSaveInCameraRoll()
        }
    }
    
    @IBAction func saveMetadata(_ sender: UIButton){
        let alert = UIAlertController(title: "Renard", message: NSLocalizedString("saveMetadataAlert", comment: ""), preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = NSLocalizedString("cameraName", comment: "")
        alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: { [self]_ in
            if let newCamera = NSEntityDescription.insertNewObject(forEntityName: "Camera", into: context) as? Camera {
                
                newCamera.name = alert.textFields?.first?.text
                newCamera.metadata = selectedObject?.metadata?.jsonString()
                
                do {
                    try context.save()
                    
                } catch {
                    let nserror = error as NSError
                    fatalError("Error al guardar datos: \(nserror), \(nserror.userInfo)")
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
}
