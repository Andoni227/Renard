//
//  Converter.swift
//  Renard
//
//  Created by Andoni Suarez on 15/04/25.
//

import Photos
import ImageIO
import MobileCoreServices
import CoreImage
import UIKit

extension UIViewController{
    func convertAndSaveAssetAsHEIF(from asset: PHAsset, completion: @escaping (Bool, Error?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, uti, _, _ in
            guard
                let data = data,
                let source = CGImageSourceCreateWithData(data as CFData, nil)
            else {
                completion(false, NSError(domain: "HEIFConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener imagen del asset"]))
                return
            }
            
            // Nombre del archivo original convertido a .heic
            var originalFilename = "converted.heic"
            if let assetResource = PHAssetResource.assetResources(for: asset).first {
                let baseName = (assetResource.originalFilename as NSString).deletingPathExtension
                originalFilename = "\(baseName).heic"
            }
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("heic")
            
            guard let destination = CGImageDestinationCreateWithURL(tempURL as CFURL, AVFileType.heic as CFString, 1, nil) else {
                completion(false, NSError(domain: "HEIFConversion", code: -2, userInfo: [NSLocalizedDescriptionKey: "No se pudo crear el destino HEIC"]))
                return
            }
            
            let compressionLevel = UserDefaults.standard.value(forKey: "compressionLevel")
            
            print("_: INICIANDO COMPRESIÓN A NIVEL \(compressionLevel ?? 0.6)")
            
            // Configura calidad máxima
            let compressionOptions: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compressionLevel ?? 0.6
            ]
            
            // Añade imagen con todos los metadatos originales
            CGImageDestinationAddImageFromSource(destination, source, 0, compressionOptions as CFDictionary)
            
            guard CGImageDestinationFinalize(destination) else {
                completion(false, NSError(domain: "HEIFConversion", code: -3, userInfo: [NSLocalizedDescriptionKey: "No se pudo finalizar la exportación HEIC"]))
                return
            }
            
            guard let heifData = try? Data(contentsOf: tempURL) else {
                completion(false, NSError(domain: "HEIFConversion", code: -4, userInfo: [NSLocalizedDescriptionKey: "No se pudo leer el archivo HEIC"]))
                return
            }
            
            // Guarda en la galería
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                
                let fileOptions = PHAssetResourceCreationOptions()
                fileOptions.originalFilename = originalFilename
                
                creationRequest.addResource(with: .photo, data: heifData, options: fileOptions)
                creationRequest.creationDate = asset.creationDate
                
                if let location = asset.location {
                    creationRequest.location = location
                }
                
            } completionHandler: { success, error in
                completion(success, error)
            }
        }
    }
}
