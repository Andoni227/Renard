//
//  SavedCamerasList.swift
//  Renard
//
//  Created by Andoni Suarez on 25/12/23.
//

import UIKit
import CoreData

class SavedCamerasList: UIViewController {

    @IBOutlet weak var table: UITableView!
    var cameras = [Camera]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("savedMetadata", comment: "")
        table.delegate = self
        table.dataSource = self
        loadCameras()
    }
    
    func loadCameras(){
        let request: NSFetchRequest<Camera> = Camera.fetchRequest()
        
        do{
            cameras = try context.fetch(request)
        }catch{
            print("Error")
        }
        
        table.reloadData()
    }

}

extension SavedCamerasList: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cameras[indexPath.row].name
        return cell
    }
}
