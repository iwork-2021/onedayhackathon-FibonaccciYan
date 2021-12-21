//
//  albumTableViewController.swift
//  Album
//
//  Created by 严思远 on 2021/12/21.
//

import UIKit

class albumTableViewController: UITableViewController {
    
    let tags = [
        "apple",
        "banana",
        "cake",
        "candy",
        "carrot",
        "cookie",
        "doughnut",
        "grape",
        "hot dog",
        "ice cream",
        "juice",
        "muffin",
        "orange",
        "pineapple",
        "popcorn",
        "pretzel",
        "salad",
        "strawberry",
        "waffle",
        "watermelon",
        "Not Sure"
    ]
    
    var photos = [String:[UIImage]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        for tag in tags {
            photos.updateValue([UIImage](), forKey: tag)
        }
        self.photos["apple"]?.append(UIImage(named: "apple.jpg")!)
        photos["orange"]?.append(UIImage(named: "orange.jpg")!)
        photos["strawberry"]?.append(UIImage(named: "strawberry.jpg")!)
        
        print(photos)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! albumTableViewCell
        let tag = tags[indexPath.row]

        // Configure the cell...
        cell.label.text! = tag
        cell.tagLabel = tag

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            let controller = segue.destination as! photoTableViewController
            let cell = sender as! albumTableViewCell
            controller.photos = photos[cell.tagLabel]!
            controller.title = cell.tagLabel
            // controller.navigationController?.navigationBar.topItem?.title = cell.tagLabel
            controller.tableView.reloadData()
        } else if segue.identifier == "toAdd" {
            let controller = segue.destination as! addViewController
            controller.addPhotoDelegate = self
        }
        
        //controller.reloadData()
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}

extension albumTableViewController: AddPhotoDelegate {
    func addPhoto(image: UIImage, tag: String) {
        self.photos[tag]?.append(image)
        self.tableView.reloadData()
    }
}
