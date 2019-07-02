//
//  ViewController.swift
//  WhatsInThePic
//
//  Created by zgaga on 2-07-2019.
//  Copyright © 2019 Hime. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var resnetModel = Resnet50()
    
    var results = [VNClassificationObservation]()
    var imagePicker = UIImagePickerController()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        imagePicker.delegate = self
        
        
        // unwrap the image to open
        if let image = imageView.image {
            processPicture(image:image )
        }
        imagePicker.delegate = self
        
    }
    
    //image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //infokey is a dictionary
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
             processPicture(image: image)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func processPicture(image:UIImage){
        if let model = try? VNCoreMLModel(for: resnetModel.model) {
        let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation]{
                    //only 20 results
                    self.results = Array(results.prefix(20))
                    
                    self.tableView.reloadData()
//                    for result in results {
//                        print ("\(result.identifier):\(result.confidence * 50) %")
//                    }
                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        }
        
    }
    
    //how many items
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    //what goes inside
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        let name = result.identifier.prefix(30)
        cell.textLabel?.text = "\(name): \(Int(result.confidence * 100))%"
        return cell
    }

    @IBAction func mediaFolderTapped(_ sender: Any) {
        
        // includes camera roll
        imagePicker.sourceType = .photoLibrary
        // after clicking folder item
        present(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        // access to the camera
        imagePicker.sourceType = .camera
        // after clicking folder item
        present(imagePicker, animated: true, completion: nil)
       
        
    }
    
}

