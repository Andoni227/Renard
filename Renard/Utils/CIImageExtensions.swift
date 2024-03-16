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
        
        if let data = ctx.heifRepresentation(of: self, format: format, colorSpace: self.colorSpace ?? ctx.workingColorSpace!, options: [:]){
            HEIFData(data)
        }else{
            HEIFData(nil)
        }
    }
}
