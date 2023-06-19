//
//  PhotoCollectionViewCell.swift
//  Renard
//
//  Created by Andoni Suarez on 13/06/23.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var checkIconView: UIImageView!
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    var asset: PHAsset?{
        didSet{
           setAsset()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var squareSize = (UIScreen.main.bounds.width / 3) * 0.8846
        squareSize > 130.0 ? squareSize = 130.0 : ()
        
        width.constant = squareSize
        height.constant = squareSize
        
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
    }
    
    func setAsset(){
        if let receivedObject = asset{
            convertPHAssetToUIImage(asset: receivedObject) { (image) in
                if let convertedImage = image {
                    self.imgView.image = convertedImage
                }
            }
        }
    }
    
    func convertPHAssetToUIImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let targetSize = CGSize(width: 200.0, height: 230.0)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            completion(image)
        }
    }
}
