//
//  CacheDataSingleton.swift
//  Renard
//
//  Created by Andoni Suarez on 25/06/23.
//

import Foundation
import Photos

internal struct assetsLibrary {
    static var shared = assetsLibrary()
    var photos: [AssetObject] = []{
        didSet{
            loadStatistics()
        }
    }
    var dataTypes: [FormatObject] = []{
        didSet{
            mostCommonFormat = dataTypes.sorted(by: { $0.count > $1.count }).first?.imageType
            lessCommonFormat = dataTypes.sorted(by: { $0.count > $1.count }).last?.imageType
        }
    }
    var maxResPhoto: String?
    var maxResPhotoAsset: PHAsset?
    var lowResPhoto: String?
    var lowResPhotoAsset: PHAsset?
    var mostCommonFormat: ImageType?
    var lessCommonFormat: ImageType?
    
    mutating func loadStatistics(){
        if let mostBiggerPhoto = photos.sorted(by: { $0.resolution > $1.resolution }).first{
            maxResPhoto = "\(mostBiggerPhoto.resolution) MP"
            maxResPhotoAsset = mostBiggerPhoto.asset
            
        }
        if let mostTinyPhoto = photos.sorted(by: { $0.resolution > $1.resolution }).last{
            lowResPhoto = "\(mostTinyPhoto.resolution) MP"
            lowResPhotoAsset = mostTinyPhoto.asset
        }
    }
    private init() { }
}
