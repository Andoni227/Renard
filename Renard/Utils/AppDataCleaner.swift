//
//  AppDataCleaner.swift
//  Renard
//
//  Created by Andoni Suarez on 13/06/23.
//

import UIKit

extension UIViewController{
    func clearTemporalDirectory() {
        let fileManager = FileManager.default
        let temporaryDirectoryURL = fileManager.temporaryDirectory

        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: temporaryDirectoryURL, includingPropertiesForKeys: nil, options: [])
            for fileURL in directoryContents {
                try fileManager.removeItem(at: fileURL)
            }
            print("Temporary directory cleared.")
        } catch {
            print("Error clearing temporary directory: \(error.localizedDescription)")
        }
    }
}
