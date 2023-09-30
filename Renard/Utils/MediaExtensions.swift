//
//  MediaExtensions.swift
//  Renard
//
//  Created by Andoni Suarez on 12/06/23.
//

import Photos
import UIKit

extension PHAsset {
    func getType() -> ImageType{
        guard self.mediaType == .image else {
            print("El PHAsset no es un archivo de imagen")
            return .NOTIMAGE
        }
        
        guard let uniformType = self.value(forKey: "uniformTypeIdentifier") as? String else {
            print("No se pudo obtener el uniformTypeIdentifier del PHAsset")
            return .UNOWNED
        }
        
        if let imageType = ImageType(rawValue: uniformType) {
            return imageType
        } else {
            return .UNOWNED
        }
    }
    
    func toImageObject(completion: @escaping (ImageObject) -> Void){
        var object: ImageObject = ImageObject.init(image: UIImage())
        
        self.toUIImage(completion: { image in
            
            object.image = image ?? UIImage()
            object.dateData = self.creationDate
            
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.requestContentEditingInput(with: options) { contentEditingInput, _ in
                guard let input = contentEditingInput else {
                    return
                }
                if let fullSizeImageURL = input.fullSizeImageURL {
                    if let imageSource = CGImageSourceCreateWithURL(fullSizeImageURL as CFURL, nil) {
                        let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any]
                        object.metadata = metadata
                        if let dateObject = metadata?["{TIFF}"] as? [String:Any]{
                            if let dateTime = dateObject["DateTime"] as? String{
                                object.dateTime = dateTime.convertDate()
                            }
                        }
                        
                        completion(object)
                    }
                }
            }
        })
    }
    
    func isLocalItem(completion: @escaping(Bool) -> Void){
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in
            if let _ = image {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func toUIImage(completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let targetSize = CGSize(width: self.pixelWidth, height: self.pixelHeight)
        
        imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            completion(image)
        }
    }
    
    func getResolution() -> Int{
        let width = Double(self.pixelWidth)
        let height = Double(self.pixelHeight)
        
        let resolution = Int((width * height / 1000000).rounded())
        
        return resolution
    }
    
    func getSize(format: sizeFormat? = .humanReadable) -> String{
        let resources = PHAssetResource.assetResources(for: self) // your PHAsset
        
        var sizeOnDisk: Int64? = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
        }
        
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary

        if let estimatedSize = sizeOnDisk{
            switch format{
            case .humanReadable:
                return estimatedSize.bytesToReadableSize()
            case .inKilobytes:
                return String(Double(estimatedSize)/1000.0)
            case .inMegabytes:
                return String(Double(estimatedSize)/1000000.0)
            case .inRawData:
                return String(estimatedSize)
            case .none:
                return NSLocalizedString("unknown", comment: "")
            }
        }else{
            return NSLocalizedString("unknown", comment: "")
        }
    }
}

enum sizeFormat{
    case humanReadable
    case inMegabytes
    case inKilobytes
    case inRawData
}
