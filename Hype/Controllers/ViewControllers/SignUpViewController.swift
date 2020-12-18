//
//  SignUpViewController.swift
//  Hype
//
//  Created by Trevor Bursach on 10/7/20.
//

import UIKit

class SignUpViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var photoContainerView: UIView!
    
    //MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var faqButton: UIButton!
    @IBOutlet weak var createUserButton: UIButton!
    
    //MARK: - Properties
    
    var image: UIImage?
    
    var viewsLaidOut = false

    //MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
        }
    }
    
    //MARK: - Actions
    
    @IBAction func createUserButtonTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text, !username.isEmpty,
              let bio = bioTextField.text else { return }
        
        UserController.shared.createUser(username: username, bio: bio, profilePhoto: image) { (result) in
            switch result {
            
            case .success(_):
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        toggleToLogIn()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        toggleToSignUp()
    }
    
    
    //MARK: - Helper Functions
    
    func fetchUser() {
        UserController.shared.fetchUser { (result) in
            switch result {
            
            case .success(_):
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
    func setupViews() {
        photoContainerView.clipsToBounds = true
        photoContainerView.addCornerRadius(radius: photoContainerView.frame.height / 2)
        self.view.backgroundColor = .spaceGray
        logInButton.rotate()
        signUpButton.rotate()
        signUpButton.tintColor = .mainText
        logInButton.tintColor = .subtleText
        helpButton.setTitleColor(.mainText, for: .normal)
        faqButton.setTitleColor(.greenAccent, for: .normal)
    }
    
    func toggleToLogIn() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.bioTextField.isHidden = true
                self.confirmPasswordTextField.isHidden = true
                self.photoContainerView.isHidden = true
                self.logInButton.tintColor = .mainText
                self.signUpButton.tintColor = .subtleText
                self.createUserButton.setTitle("Log Me In!", for: .normal)
                self.helpButton.setTitle("Forgot Password", for: .normal)
                self.faqButton.setTitle("Hint", for: .normal)
                self.usernameTextField.text = UserController.shared.currentUser?.username
            }
        }
    }
    
    func toggleToSignUp() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.confirmPasswordTextField.isHidden = false
                self.bioTextField.isHidden = false
                self.photoContainerView.isHidden = false
                self.logInButton.tintColor = .subtleText
                self.signUpButton.tintColor = .mainText
                self.createUserButton.setTitle("Sign Me Up1", for: .normal)
                self.helpButton.setTitle("Help", for: .normal)
                self.faqButton.setTitle("FAQ", for: .normal)
                self.usernameTextField.text = ""
            }
        }
    }

} // END OF CLASS

extension SignUpViewController: PhotoSelectorDelegate {
    func photoPickerSelectedimage(image: UIImage) {
        self.image = image
    }
    
    
}
