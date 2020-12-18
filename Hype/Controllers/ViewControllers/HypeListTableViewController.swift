//
//  HypeListTableViewController.swift
//  Hype
//
//  Created by Trevor Bursach on 10/5/20.
//

import UIKit

class HypeListTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var refresh: UIRefreshControl = UIRefreshControl()
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        loadData()
        self.tableView.backgroundColor = .spaceGray
    }
    
    //MARK: - Actions
    
    @IBAction func composeHypeButtonTapped(_ sender: Any) {
        presentHypeAlert(nil)
    }
    
    //MARK: - Helper/Class Methods
    
    func setUpViews() {
        refresh.attributedTitle = NSAttributedString(string: "Pull to see new Hypes")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            
            case .success(let hypes):
                guard let hypes = hypes else { return }
                HypeController.shared.hypes = hypes
                self.updateViews()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func presentHypeAlert(_ hype: Hype?) {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "What is hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let addHypeAction = UIAlertAction.init(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            
            if let hype = hype {
                hype.body = text
                HypeController.shared.update(hype) { (result) in
                    switch result {
                    
                    case .success(_):
                        self.updateViews()
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            } else {
            
                HypeController.shared.saveHype(with: text, hypePhoto: self.image) { (result) in
                switch result {
                
                case .success(let hype):
                    guard let hype = hype else { return }
                    HypeController.shared.hypes.insert(hype, at: 0)
                    self.updateViews()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addHypeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
//        let hypeToDisplay = HypeController.shared.hypes[indexPath.row]
//        cell.textLabel?.text = hypeToDisplay.body
//        cell.detailTextLabel?.text = hypeToDisplay.timestamp.formatDate()
//        cell.imageView?.image = hypeToDisplay.hypePhoto
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHype = HypeController.shared.hypes[indexPath.row]
        guard UserController.shared.currentUser?.recordID == selectedHype.userReference?.recordID else { return }
        presentHypeAlert(selectedHype)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hypeToDelete = HypeController.shared.hypes[indexPath.row]
            guard UserController.shared.currentUser?.recordID == hypeToDelete.userReference?.recordID else { return }
            guard let indexOfHypeToDelete = HypeController.shared.hypes.firstIndex(of: hypeToDelete) else { return }
            HypeController.shared.delete(hypeToDelete) { (result) in
                switch result {
                
                case .success(let success):
                    if success {
                        HypeController.shared.hypes.remove(at: indexOfHypeToDelete)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
   
}
