//
//  FeedTableViewController.swift
//  AC3.2-Final
//
//  Created by Simone on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewController: UITableViewController {
    var databaseReference: FIRDatabaseReference!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        //grab posts
        getFeed()
        
        navigationItem.title = "Unit6Final-staGram"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeed()
    }
    
    func getFeed() {
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            var newPosts: [Post] = []
            let value = snapshot.value as? NSDictionary
            for keys in value! {
                let image = keys.key
                print(image)
                let commentDict = keys.value as? [String:Any]
                if let commentUnwrapped = commentDict {
                for _ in commentUnwrapped {
//                    print(commentUnwrapped)
                    if let comment = commentDict?["comment"] {
//                        print(comment)
                        let post = Post(feedImage: image as? String ?? "-Kcyi9CKNFJ_WaReblkj", comment: comment as? String ?? "")
                        newPosts.append(post)
                    }
                }
                }
            }
            
            self.posts = newPosts
            self.tableView?.reloadData()
        })
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! FeedTableViewCell

        let post = posts[indexPath.row]
        cell.commentLabel.text = post.comment
        
        let storage = FIRStorage.storage()
        
        if let feedImg = post.feedImage {
        // Create a storage reference from our storage service
        let storageRef = storage.reference()//forURL: "gs://ac-32-final.appspot.com")
        let spaceRef = storageRef.child("images/\(feedImg)")
        spaceRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                cell.largeFeedImg.image = image
            }
        }
        }
        
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
