//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Trevor Bursach on 10/8/20.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var hypeTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    //MARK: - Properties
    
    var image: UIImage?
    
    //MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTextField.text, !text.isEmpty else { return }
        HypeController.shared.saveHype(with: text, hypePhoto: image) { (result) in
            switch result {
            
            case .success(_):
                self.dismissView()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    //MARK: - Helper Functions
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    func setupViews() {
        photoContainerView.layer.cornerRadius = 32
        photoContainerView.clipsToBounds = true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoPickerVC" {
            let destination = segue.destination as? PhotoPickerViewController
            destination?.delegate = self
        }
       
    }

} // END OF CLASS

extension HypePhotoViewController: PhotoSelectorDelegate {
    func photoPickerSelectedimage(image: UIImage) {
        self.image = image
    }
}
