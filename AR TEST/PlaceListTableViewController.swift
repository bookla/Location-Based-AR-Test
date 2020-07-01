//
//  PlaceListTableViewController.swift
//  AR TEST
//
//  Created by Book Lailert on 1/7/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class PlaceListTableViewController: UITableViewController {
    
    var placeData = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let places = UserDefaults.standard.array(forKey: "places") {
            if let placeList = places as? [[String: Any]] {
                placeData = placeList
                self.tableView.reloadData()
            } else {
                navigationController?.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placeData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceTableViewCell

        cell.name.text = placeData[indexPath.row]["name"] as? String
        var altitude = "10m"
        if let alt = placeData[indexPath.row]["alt"] as? Double {
            altitude = String(alt) + "m"
        }
        cell.altitude.text = "Altitude: " + altitude

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func editData(at row: Int, name:String, altitude: Double) {
        let currentLat = placeData[row]["lat"] as! Double
        let currentLong = placeData[row]["long"] as! Double
        let newData = ["name": name, "lat": currentLat, "long": currentLong, "alt": altitude] as [String : Any]
        placeData[row] = newData
        UserDefaults.standard.set(placeData, forKey: "places")
        self.tableView.reloadData()
    }
    
    func deleteData(at row: Int) {
        placeData.remove(at: row)
        UserDefaults.standard.set(placeData, forKey: "places")
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit a place", message: "Make edits or delete this place", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.placeData[indexPath.row]["name"] as? String
        }
        alert.addTextField { (textField) in
            if let alt = self.placeData[indexPath.row]["alt"] as? Double {
                textField.text = String(describing: alt)
            } else {
                textField.placeholder = "Altitude (Default: 10m)"
            }
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let textField = alert.textFields![0]
            let name = textField.text!
            if let alt =  alert.textFields![1].text {
                if alt.isNumber {
                    self.editData(at: indexPath.row, name: name, altitude: Double(alt)!)
                } else {
                    self.editData(at: indexPath.row, name: name, altitude: 10)
                }
            } else {
                self.editData(at: indexPath.row, name: name, altitude: 10)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (nil) in
            self.deleteData(at: indexPath.row)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
