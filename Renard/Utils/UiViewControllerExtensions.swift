//
//  UiViewControllerExtensions.swift
//  Renard
//
//  Created by Andoni Suarez on 11/06/23.
//

import UIKit
import Photos

extension UIViewController{
    func exportImageAsJPG(image: UIImage, quality: CGFloat) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            return nil
        }
        return imageData
    }
    
    func addMetadataToCIImage(ciImage: CIImage, metadata: [String: Any]) -> CIImage {
        var properties = ciImage.properties
        
        // Agregar los metadatos al diccionario de propiedades existente
        for (key, value) in metadata {
            if key != "Orientation"{
                properties[key] = value
            }
        }
        
        // Crear un nuevo CIImage con las propiedades actualizadas
        var newCIImage = ciImage.applyingFilter("CIAffineTransform",
                                                parameters: [
                                                    kCIInputTransformKey: NSValue(cgAffineTransform: CGAffineTransform.identity)
                                                ])
        
        newCIImage = newCIImage.settingProperties(properties)
        
        return newCIImage
    }
    
    func addCustomDateTimeToCIImage(ciImage: CIImage, dateTime: String) -> CIImage {
        // Obtener los metadatos existentes de la CIImage
        var properties = ciImage.properties
        
        // Crear un nuevo diccionario de metadatos con la fecha y hora personalizada
        let customMetadata = [
            kCGImagePropertyExifDateTimeOriginal as String: dateTime
        ]
        
        // Combinar los metadatos existentes con los nuevos metadatos
        properties.merge(customMetadata) { (_, new) in new }
        
        // Crear una nueva CIImage con los metadatos actualizados
        let newCIImage = ciImage.oriented(forExifOrientation: 1)
        newCIImage.settingProperties(properties)
        
        return newCIImage
    }
    
    func delete(assets: [PHAsset]){
        var identifiers: [String] = []
        
        for asset in assets{
            identifiers.append(asset.localIdentifier)
        }
        
        PHPhotoLibrary.shared().performChanges({
            // Obtén una referencia al PHAsset que deseas eliminar
            let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            
            var itemsToDelete: [PHAsset] = []
            
            assetToDelete.enumerateObjects({ photo ,_,_ in
                itemsToDelete.append(photo)
            })
            // Crea un PHAssetChangeRequest para eliminar el asset
            PHAssetChangeRequest.deleteAssets(itemsToDelete as NSArray)
            
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: Notification.Name("updateLibrary"), object: nil)
                })
            }
        })
    }
    
    func exportImage(asset: ImageObject,_ changeBlock: @escaping (Bool) -> Void){
        print("_: LLAMADO A FUNCIÓN DE EXPORT")
        let ctx = CIContext()
        if var ciImage = CIImage(image: asset.image){
            
            if let photoMetaData = asset.metadata{
                ciImage = addMetadataToCIImage(ciImage: ciImage, metadata: photoMetaData)
            }
            
            if let dateTime = asset.dateTime{
                ciImage = addCustomDateTimeToCIImage(ciImage: ciImage, dateTime: dateTime)
            }
            
            if let data = ctx.heifRepresentation(of: ciImage, format: .RGBA8, colorSpace: ctx.workingColorSpace!, options: [:]){
                
                PHPhotoLibrary.shared().performChanges {
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: data, options: nil)
                    creationRequest.creationDate = asset.dateData ?? asset.dateTime?.stringToDate(format: "yyyy-MM-dd HH:mm:ss")
                    
                } completionHandler: { success, error in
                    changeBlock(success)
                }
            }
        }
    }
}

extension String{
    func convertDate() -> String{
        if self.components(separatedBy: " ").count == 2{
            let dateArray =  self.components(separatedBy: " ")
            let date = dateArray.first?.replacingOccurrences(of: ":", with: "-")
            let time = dateArray.last
            return "\(date ?? "") \(time ?? "")"
        }else{
            return self
        }
    }
}
