//
//  UiViewControllerExtensions.swift
//  Renard
//
//  Created by Andoni Suarez on 11/06/23.
//

import UIKit
import Photos

extension UIViewController{
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
    
    func isRunningOnMac() -> Bool {
      #if os(macOS)
        return true
      #else
        return false
      #endif
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
