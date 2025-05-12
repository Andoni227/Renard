//
//  IncomingImage.swift
//  Renard
//
//  Created by Andoni Suarez on 11/05/25.
//

import Foundation

class IncomingFileManager {
    static let shared = IncomingFileManager()
    private init() {}

    var pendingImageURL: URL?
}
