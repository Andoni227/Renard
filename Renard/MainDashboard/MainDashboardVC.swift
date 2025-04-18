//
//  MainDashboardVC.swift
//  Renard
//
//  Created by Andoni Suarez on 13/06/23.
//

import UIKit
import Photos

class MainDashboardVC: UIViewController {
    
    @IBOutlet weak var titleCollectionView: UICollectionView!
    @IBOutlet weak var photoLibraryCollectionView: UICollectionView!
    @IBOutlet weak var btnExport: UIButton!
    @IBOutlet weak var btnSelect: UIBarButtonItem!
    @IBOutlet weak var swtchView: UIView!
    @IBOutlet weak var swtch: UISwitch!
    @IBOutlet weak var lblSwtch: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var photos: [AssetObject] = []
    var dataTypes: [FormatObject] = []
    var currentType: ImageType?
    var cacheImages: [AssetObject] = []{
        didSet{
            if enableSelection{
                if cacheImages.filter({ $0.isSelected  == true }).count > 0{
                    btnExport.isHidden = false
                    if let savedStatus = UserDefaults.standard.value(forKey: "deleteByDefault"){
                        swtch.isOn = savedStatus as? Bool ?? true
                    }
                    swtchView.isHidden = false
                    bottomView.isHidden = false
                    
                    var totalSize: Int64 = Int64(0.0)
                    for item in cacheImages.filter({ $0.isSelected  == true }){
                        if let imageSize = Int64(item.asset.getSize(format: .inRawData)){
                            totalSize += imageSize
                        }
                    }
                    lblSwtch.text = "\(NSLocalizedString("deleteAfterSave", comment: "")) (\(totalSize.bytesToReadableSize()))"
                }else{
                    btnExport.isHidden = true
                    swtchView.isHidden = true
                    bottomView.isHidden = true
                }
            }
        }
    }
    var imagesToExport: [AssetObject] = []
    var imagesToExportMirror: [AssetObject] = []
    var enableSelection = false
    let refreshControl = UIRefreshControl()
    var alertHasShowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleCollectionView.delegate = self
        titleCollectionView.dataSource = self
        
        photoLibraryCollectionView.delegate = self
        photoLibraryCollectionView.dataSource = self
        
        photoLibraryCollectionView.backgroundColor = UIColor.renardBackgroundHeavy()
        
        titleCollectionView.backgroundColor = UIColor.renardDarkBlue()
        self.view.backgroundColor = UIColor.renardDarkBlue()
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.renardBoldBlue()
        
        registerCells()
        setUpRefreshControl()
        
        customizeView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLibrary), name: Notification.Name("updateLibrary"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestPhotoLibraryAuthorization()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerCells(){
        photoLibraryCollectionView.register(.init(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        titleCollectionView.register(.init(nibName: TitleCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
    }
    
    func customizeView(){
        btnExport.layer.cornerRadius = 10.0
        btnExport.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        lblSwtch.text = NSLocalizedString("deleteAfterSave", comment: "")
        
        swtchView.backgroundColor = UIColor.renardDarkBlue()
        bottomView.backgroundColor = UIColor.renardDarkBlue()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.montserratMedium(ofSize: 16.0)]
        
        btnExport.titleLabel?.font =  UIFont.montserratMedium(ofSize: 15.0)
         
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.montserratMedium(ofSize: 15.0)
        ]
        btnSelect.setTitleTextAttributes(attributes, for: .normal)
    }
    
    func setUpRefreshControl(){
        photoLibraryCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateLibrary), for: UIControl.Event.valueChanged)
    }
    
    func requestPhotoLibraryAuthorization(){
        PHPhotoLibrary.requestAuthorization { [self] status in
            DispatchQueue.main.async { [self] in
                switch status {
                case .authorized:
                    fetchPhotos()
                case .denied, .restricted:
                    showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("cameraPermission", comment: ""), buttonText: NSLocalizedString("openSettings", comment: ""), handler: {_ in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    })
                case .notDetermined:
                    requestPhotoLibraryAuthorization()
                case .limited:
                    fetchPhotos()
                @unknown default:
                    break
                }
            }
        }
    }
    
    func fetchPhotos() {
        
        showLoading(title: NSLocalizedString("loadingLibrary", comment: ""))
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var avaliableFormats: Set<ImageType> = []
        
        fetchResult.enumerateObjects { (asset, _, _) in
                self.photos.append(AssetObject.init(asset: asset, format: asset.getType(), resolution: asset.getResolution()))
                avaliableFormats.insert(asset.getType())
        }
        
        for format in avaliableFormats{
            dataTypes.append(FormatObject.init(imageType: format, count: photos.filter({ $0.format == format }).count))
        }
        
        dataTypes = dataTypes.sorted(by: { $0.count > $1.count })
        
        assetsLibrary.shared.photos = photos
        assetsLibrary.shared.dataTypes = dataTypes
        
        dataTypes = dataTypes.filter({ $0.imageType != .HEIC })
        photos = photos.filter({ $0.format != .HEIC })
        
        var updateScroll = false
        
        if let selectedType = currentType{
            if photos.filter({ $0.format == selectedType }).count > 0{
                cacheImages = photos.filter({ $0.format == selectedType })
            }else{
                currentType = dataTypes.first?.imageType
                cacheImages = photos.filter({ $0.format == dataTypes.first?.imageType })
                updateScroll = true
            }
        }else{
            currentType = dataTypes.first?.imageType
            cacheImages = photos.filter({ $0.format == dataTypes.first?.imageType })
            updateScroll = true
        }
        
        
        hideLoading {
            DispatchQueue.main.async { [self] in
                btnSelect.title = NSLocalizedString("selectTxt", comment: "")
                enableSelection = false
                refreshControl.endRefreshing()
                titleCollectionView.reloadData()
                photoLibraryCollectionView.reloadData()
                if updateScroll{
                    titleCollectionView.scrollToItem(at: [0,0], at: .left, animated: true)
                }
            }
        }
    }
    
    func fetchCompressions(){
        if imagesToExport.count > 0{
            if let image = imagesToExport.first{
                convertAndSaveAssetAsHEIF(from: image.asset, completion: { success, error in
                    if success == false{
                        self.hideLoading(completion: {
                            self.imagesToExport.removeAll()
                            self.imagesToExportMirror.removeAll()
                            self.showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("unknownErrorSaving", comment: ""))
                        })
                    }else {
                        if self.imagesToExport.count > 0{
                            _ = self.imagesToExport.removeFirst()
                            self.fetchCompressions()
                        }
                    }
                })
            }
        }else{
            self.hideLoading {
                self.showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("exportComplete", comment: ""), handler: { [self] _ in
                    if swtch.isOn{
                        var assetsToRemove: [PHAsset] = []
                        
                        for item in imagesToExportMirror{
                            assetsToRemove.append(item.asset)
                        }
                        
                        self.delete(assets: assetsToRemove)
                    }
                })
                self.updateLibrary()
                
            }
        }
    }
    
    func checkSelectiosn(){
        if alertHasShowed == false{
            let selectedPhotos = cacheImages.filter({ $0.isSelected == true }).count
            if selectedPhotos > 40{
                showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("limitSelectedImages", comment: ""), handler: { _ in
                    self.alertHasShowed = true
                })
            }
        }
    }
    
    func startConvertion(){
        let selectedObjects = cacheImages.filter({ $0.isSelected == true })
        if  selectedObjects.count > 0{
            print("_: MÁS DE UN ELEMENTO SELECCIONADO, INICIANDO EXPORTACIÓN")
            showLoading()
            imagesToExport = selectedObjects
            imagesToExportMirror = selectedObjects
            fetchCompressions()
        }
    }
    
    @objc func updateLibrary(){
        photos.removeAll()
        dataTypes.removeAll()
        cacheImages.removeAll()
        fetchPhotos()
    }
    
    @IBAction func saveSelectedImages(_ sender: UIButton){
        print("_: CLICK BOTÓN DE GUARDAR")
        if currentType == .AVIF{
            let alert = UIAlertController(title: "Renard", message: NSLocalizedString("saveAVIFAlert", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: { [self]_ in
                startConvertion()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
            self.present(alert, animated: true)
        }else{
            startConvertion()
        }
    }
    
    @IBAction func enableSelection(_ sender: UIBarButtonItem){
        DispatchQueue.main.async { [self] in
            if currentType == .HEIC{
                showAlertWithLottie(lottie: .FoxUpset, labelText: NSLocalizedString("imagesAlreadyHEIF", comment: ""))
            }else{
                if sender.title == NSLocalizedString("selectTxt", comment: ""){
                    enableSelection = true
                    sender.title = NSLocalizedString("cancel", comment: "")
                }else{
                    sender.title = NSLocalizedString("selectTxt", comment: "")
                    enableSelection = false
                    btnExport.isHidden = true
                    swtchView.isHidden = true
                    bottomView.isHidden = true
                    
                    for n in 0..<cacheImages.count{
                        cacheImages[n].isSelected = false
                    }
                    
                    photoLibraryCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func importFromFiles(_ sender: UIBarButtonItem){
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
}

extension MainDashboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == titleCollectionView{
            return dataTypes.count
        }else{
            if let type = currentType{
                return photos.filter({ $0.format == type }).count
            }else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == titleCollectionView{
            let cell = titleCollectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as! TitleCollectionViewCell
            cell.lblTitle.text = "\(dataTypes[indexPath.row].imageType.getName) (\(dataTypes[indexPath.row].count))"
            cell.accessibilityElements = [dataTypes[indexPath.row].imageType]
            currentType == dataTypes[indexPath.row].imageType ? cell.setSelectedStyle() : cell.setUnselectedStyle()
            return cell
        }else{
            if let _ = currentType{
                let photoCell = photoLibraryCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
                photoCell.asset = cacheImages[indexPath.row].asset
                if enableSelection == true{
                    photoCell.checkIconView.isHidden = !(cacheImages[indexPath.row].isSelected ?? false)
                    photoCell.imgView.alpha = cacheImages[indexPath.row].isSelected ?? false ? 0.5 : 1.0
                }else{
                    photoCell.imgView.alpha = 1.0
                    photoCell.checkIconView.isHidden = true
                }
                return photoCell
            }else{
                return UICollectionViewCell()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == titleCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! TitleCollectionViewCell
            if let selectedType = cell.accessibilityElements?.first as? ImageType{
                if currentType == selectedType{
                    if photos.count > 0{
                        self.photoLibraryCollectionView.scrollToItem(at: [0,0], at: .top, animated: true)
                    }
                }else{
                    currentType = selectedType
                    cacheImages = photos.filter({ $0.format == selectedType })
                    cell.setSelectedStyle()
     
                    self.photoLibraryCollectionView.reloadData()
                    self.titleCollectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.titleCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    })
                }
            }
        }
        
        if collectionView == photoLibraryCollectionView{
            if enableSelection{
                let cell = photoLibraryCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                if cacheImages[indexPath.row].isSelected == true{
                    cell.imgView.alpha = 1.0
                    cell.checkIconView.isHidden = true
                    cacheImages[indexPath.row].isSelected = false
                }else{
                    cell.imgView.alpha = 0.5
                    cell.checkIconView.isHidden = false
                    cacheImages[indexPath.row].isSelected = true
                }
                checkSelectiosn()
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewVC") as? ImagePreviewVC {
                    vc.receivedAsset =  cacheImages[indexPath.row].asset
                    self.present(vc, animated: true)
                }
            }
        }
    }
}

extension MainDashboardVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //let convertedFiles: [ImageObject] = []
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else {
                print("No se pudo acceder al recurso seguro.")
                return
            }

            url.stopAccessingSecurityScopedResource()
        }
        
        /*for file in convertedFiles{
            
        } */
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Selección de documentos cancelada")
    }
}
