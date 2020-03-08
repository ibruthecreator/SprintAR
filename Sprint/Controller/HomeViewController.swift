//
//  HomeViewController.swift
//  Sprint
//
//  Created by Mohammed Ibrahim on 2020-03-07.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var joinWorkspaceButton: UIButton!
    @IBOutlet weak var startNewWorkspaceButton: UIButton!
    @IBOutlet weak var existingWorkspaceTextField: UITextField!
    @IBOutlet weak var newWorkspaceIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    // MARK: - Setup Views
    func setupViews() {
        joinWorkspaceButton.layer.cornerRadius = 8
        startNewWorkspaceButton.layer.cornerRadius = 8
        
        newWorkspaceIDLabel.text = randomCode()
    }
    
    // MARK: - Join Existing Workspace
    @IBAction func joinExistingWorkspace(_ sender: Any) {
        if let workspaceID = existingWorkspaceTextField.text {
            SprintDataController.shared.isWorkspaceOpen(withID: workspaceID) { (doesExist) in
                if doesExist {
                    print("Exists")
                } else {
                    self.displayAlert(withTitle: "Invalid Workspace ID", andMessage: "Please make sure the workspace you are trying to join already exists and has at least one active user. Also, be sure to check your internet connection to make sure you're online.")
                }
            }
        }
    }
    
    // MARK: - Start New Workspace
    @IBAction func startNewWorkspace(_ sender: Any) {
        self.performSegue(withIdentifier: "startNewWorkspace", sender: self)
    }
    
    // MARK: - Random Generator
    func randomCode(ofLength length: Int = 6) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    // MARK: - Dismiss Keyboard
    @IBAction func didEndOnExit(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    // MARK: - Display Alert
    func displayAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WorkspaceViewController
        if segue.identifier == "startNewWorkspace" {
            destinationVC.workspaceID = newWorkspaceIDLabel.text!
        } else {
            destinationVC.workspaceID = existingWorkspaceTextField.text!
        }
    }
}
