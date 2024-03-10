//
//  OpenFinderUtility.swift
//  Renard
//
//  Created by Andoni Suarez on 15/02/24.
//

import UIKit

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBAction func openDocumentPicker(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print("Archivo seleccionado: \(url)")
            // Aquí puedes trabajar con los archivos seleccionados
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Selección de documentos cancelada")
    }
}
