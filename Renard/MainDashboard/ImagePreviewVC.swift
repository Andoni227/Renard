//
//  ViewController.swift
//  Renard
//
//  Created by Andoni Suarez on 11/06/23.
//

import UIKit
import Lottie
import Photos

class ImagePreviewVC: UIViewController{
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var btnSaveMetadata: UIBarButtonItem!
    @IBOutlet weak var swtch: UISwitch!
    @IBOutlet weak var lblIndicator: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var swtchView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var receivedAsset: PHAsset?
    var selectedObject: ImageObject?
    
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
        btnSaveMetadata.setTitleTextAttributes(attributes, for: .normal)
        btnSaveMetadata.title = NSLocalizedString("saveMetadataBtn", comment: "")
        lblIndicator.text = NSLocalizedString("deleteAfterSaveOne", comment: "")
        lblIndicator.font = UIFont.montserratMedium(ofSize: 15.0)
        lblTitle.font = UIFont.montserratMedium(ofSize: 15.0)
        lblTitle.textColor = .white
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
    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    @IBAction func exportImage(_ sender: UIButton){
        showLoading()
        
        let ctx = CIContext()
        if var ciImage = CIImage(image: selectedObject?.image ?? UIImage()){
            
            if let photoMetaData = selectedObject?.metadata{
                ciImage = addMetadataToCIImage(ciImage: ciImage, metadata: photoMetaData)
            }
            
            if let dateTime = selectedObject?.dateTime{
                ciImage = addCustomDateTimeToCIImage(ciImage: ciImage, dateTime: dateTime)
            }
            
            let data = ctx.heifRepresentation(of: ciImage, format: .RGBA8, colorSpace: ctx.workingColorSpace!, options: [:])
            
            let activityViewController = UIActivityViewController(activityItems: [data!], applicationActivities: nil)
            self.hideLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                    self.present(activityViewController, animated: true, completion: nil)
                })
            }
        }
        
    }
    
    @IBAction func saveToCameraRoll(_ sender: UIButton){
        showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            let ctx = CIContext()
            if var ciImage = CIImage(image: selectedObject?.image ?? UIImage()){
                
                if let photoMetaData = selectedObject?.metadata{
                    ciImage = addMetadataToCIImage(ciImage: ciImage, metadata: photoMetaData)
                }
                
                if let dateTime = selectedObject?.dateTime{
                    ciImage = addCustomDateTimeToCIImage(ciImage: ciImage, dateTime: dateTime)
                }
                
                if let data = ctx.heifRepresentation(of: ciImage, format: .RGBA8, colorSpace: ctx.workingColorSpace!, options: [:]){
                    
                    PHPhotoLibrary.shared().performChanges {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: data, options: nil)
                        creationRequest.creationDate = self.selectedObject?.dateData ?? self.selectedObject?.dateTime?.stringToDate(format: "yyyy-MM-dd HH:mm:ss")
                        
                    } completionHandler: { success, error in
                        if let error = error {
                            self.showAlertWithLottie(lottie: .FoxUpset, labelText: "\(NSLocalizedString("unknownErrorSaving", comment: "")) \n\(error.localizedDescription)")
                        } else {
                            self.clearTemporaryDirectory()
                        }
                    }
                    
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
                }
            }
        })
    }
    
    @IBAction func saveMetadata(_ sender: UIButton){
        let alert = UIAlertController(title: "Renard", message: NSLocalizedString("saveMetadataAlert", comment: ""), preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = NSLocalizedString("cameraName", comment: "")
        alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
    }
}
