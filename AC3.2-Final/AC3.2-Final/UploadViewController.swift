//
//  UploadViewController.swift
//  AC3.2-Final
//
//  Created by Simone on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var databaseReference: FIRDatabaseReference!
    var user: FIRUser?

    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonHandled))
        
        //set up trigger for image picker
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImagePickerSelected)))
        uploadImageView.isUserInteractionEnabled = true
        commentTextView.text = "Enter description here"

        self.databaseReference = FIRDatabase.database().reference().child("posts")
        //sign in anonymously to make uploading in the simulator easier
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
            if let error = error {
                print(error)
            } else {
                self.user = user
            }
        })
    }
    
    
    func profileImagePickerSelected() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImg
        }
        
        if let selectedImage = selectedImage {
            self.uploadImageView.image = selectedImage
            self.uploadImageView.contentMode = .scaleAspectFit
        }
        
        var data = Data()
        data = UIImageJPEGRepresentation(uploadImageView.image!, 0.8)! as Data
        // set upload path
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "gs://ac-32-final.appspot.com")
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        let imageRef = storage.child("posts")
        
        imageRef.put(data, metadata: metaData) { (metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                //store downloadURL
                
                imageRef.downloadURL(completion: { (url, error) in
                    
                
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
            ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["posts": downloadURL])
                    
                })
            }
            
        }
        self.dismiss(animated: true, completion: nil)
        
        let alert = UIAlertController(title: "Photo Uploaded", message: "Your photo has uploaded", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)

    }

    
    

   
     func doneButtonHandled(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fc = storyboard.instantiateViewController(withIdentifier: "categories")
        self.present(fc, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
