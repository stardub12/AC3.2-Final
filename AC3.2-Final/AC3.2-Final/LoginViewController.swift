//
//  ViewController.swift
//  AC3.2-Final
//
//  Created by Jason Gresh on 2/14/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class LoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Did not finish with constraints for view after image is selected.
    
    @IBOutlet weak var meatlyLogoImage: UIImageView!
    @IBOutlet weak var meatlyTopMargin: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up trigger for image picker
        meatlyLogoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImagePickerSelected)))
        meatlyLogoImage.isUserInteractionEnabled = true
    }
    
    //MARK: - Actions
    
    @IBAction func handleLoginButton(_ sender: UIButton) {
        loginSelected()
    }
    
    @IBAction func handleRegisterButton(_ sender: UIButton) {
//        registerSelected()
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if user != nil {
                    //self.updateInterface()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let fc = storyboard.instantiateViewController(withIdentifier: "controller")
                    self.present(fc, animated: true, completion: nil)
                    
                }
                else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    //MARK: - Utility
    
    func loginSelected() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                //present view controller
            } catch {
                print(error)
            }
            
        } else {
            
            guard let email = emailTextField.text,
                let password = passwordTextField.text else {
                    print("Invalid email/password")
                    return
            }
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if user != nil {
                    //if login is successful
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let fc = storyboard.instantiateViewController(withIdentifier: "controller")
                    self.present(fc, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Login Error", message: "Email/Password is incorrect", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func registerSelected() {
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                print("Information is invalid")
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            //user is authenticated
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("images").child("\(imageName).jpg")
            
            if let profileImg = self.profileImageView.image,
                let uploadPic = UIImageJPEGRepresentation(profileImg, 0.8) {
                
                let metadata = FIRStorageMetadata()
                metadata.cacheControl = "public,max-age=300";
                metadata.contentType = "image/jpeg";
                
                storageRef.put(uploadPic, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if let profileImgURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["email": email, "profileImageUrl": profileImgURL]
                        
                        self.registerUserWithUID(uid, values: values as [String : AnyObject])
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let fc = storyboard.instantiateViewController(withIdentifier: "feedController")
                        self.present(fc, animated: true, completion: nil)

                    }
                    
                })
            }
        })
    }
    
    private func registerUserWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "gs://ac-32-final.appspot.com")
        let userRef = ref.child("users").child(uid)
        
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    func profileImagePickerSelected() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        view.layoutIfNeeded()
        //change storyboard constraints
        if self.meatlyTopMargin.constant == 50.0 {
            self.meatlyTopMargin.constant = 230.0
        } else {
            self.meatlyTopMargin.constant = 50.0
        }
        self.view.layoutIfNeeded()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImg
        }
        
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}

