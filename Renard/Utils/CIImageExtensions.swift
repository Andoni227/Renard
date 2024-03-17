//
//  CIImageExtensions.swift
//  Renard
//
//  Created by Andoni Suarez on 16/03/24.
//

import UIKit

extension CIImage{
    func toHEIFData(HEIFData: @escaping (Data?) -> Void){
        let ctx = CIContext()
        var format: CIFormat = .RGBA8
        
        if #available(iOS 17.0, *){
            format = .RGB10
        }
        
        var colorSpace = self.colorSpace ?? ctx.workingColorSpace!
        
        if UserDefaults.standard.bool(forKey: "maximumCompression"){
            colorSpace = ctx.workingColorSpace!
        }
        
        if let data = ctx.heifRepresentation(of: self, format: format, colorSpace: colorSpace, options: [:]){
            HEIFData(data)
        }else{
            HEIFData(nil)
        }
    }
}
