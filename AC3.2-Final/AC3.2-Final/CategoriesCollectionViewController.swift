//
//  CategoriesCollectionViewController.swift
//  AC3.2-Final
//
//  Created by Simone on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

//Ran out of time but tried to load something quickly

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class CategoriesCollectionViewController: UICollectionViewController {
    var databaseReference: FIRDatabaseReference!
    var images = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.databaseReference = FIRDatabase.database().reference().child("posts")

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

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
            
            self.images = newPosts
            self.collectionView?.reloadData()
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let imageView = UIImageView(frame: CGRect(x: 50, y: 0, width: self.view.frame.width, height: 50))
        cell.contentView.addSubview(imageView)
        
        let storage = FIRStorage.storage()
        
        if let feedImg = images[indexPath.item].feedImage {
            // Create a storage reference from our storage service
            let storageRef = storage.reference()//forURL: "gs://ac-32-final.appspot.com")
            let spaceRef = storageRef.child("images/\(feedImg)")
            spaceRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    imageView.image = image
                }
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
