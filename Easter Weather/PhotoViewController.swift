//
//  PhotoViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/11/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    var currentTemperature:String!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: –
    override func viewDidLoad() {
        
        temperatureLabel.text = currentTemperature
        takeAPhoto()
    }
    
    // MARK: Image Picker Delegate Methods and Support
    
    // Called after the user hits cancel in the image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func takeAPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    // Called after the user picks an image in the image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        // set the image view's image to the image that was selected
        
        print("picked photo")
        imageView.image = image
        print("set image")
        self.dismissViewControllerAnimated(true, completion: nil)
        showAlert()
        
        
    }
    func showAlert(){
        let alert = UIAlertController(title: "Do what with the picture?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in})
        alert.addAction(dismissAction)
        
        let saveAction = UIAlertAction(title: "Save to Camera Roll", style: .Default, handler: { (action) -> Void in self.savePhoto()})
        alert.addAction(saveAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .Default, handler: {(action) -> Void in self.sharePhoto()})
        alert.addAction(shareAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func savePhoto(){
        UIImageWriteToSavedPhotosAlbum(generateImageWithText(), nil, nil, nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // saves the picture with text
    private func generateImageWithText() -> UIImage {
        
        self.navigationController?.navigationBarHidden = true
        //navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
                                          afterScreenUpdates: true)
        let image : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController?.navigationBarHidden = false
        return image
    }
    func sharePhoto(){
        let activityController = UIActivityViewController(activityItems: [generateImageWithText()], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
}
