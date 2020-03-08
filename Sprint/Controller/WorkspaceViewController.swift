//
//  WorkspaceViewController.swift
//  Sprint
//
//  Created by Mohammed Ibrahim on 2020-03-07.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class WorkspaceViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var workspaceIDBlurView: UIVisualEffectView!
    @IBOutlet weak var workspaceIDLabel: UILabel!
    @IBOutlet weak var largePostItNote: CanvasView!
    @IBOutlet weak var minimizedPostItNode: UIView!
    
    @IBOutlet weak var largePostItNoteEditStackView: UIStackView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    // Sticky notes buttons
    @IBOutlet weak var stickyNotesStackView: UIStackView!
    @IBOutlet weak var blueStickyNotes: UIButton!
    @IBOutlet weak var greenStickyNoteButton: UIButton!
    @IBOutlet weak var orangeStickyNoteBUtton: UIButton!
    @IBOutlet weak var redStickyNoteButton: UIButton!
    @IBOutlet weak var yellowStickyNoteButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    var currentImageView: UIImageView = UIImageView(image: UIImage(named: "blue"))
        
    // MARK: - Variables
    var workspaceID: String = ""
    let scene = SCNScene()
    var grids = [Grid]()

    var minimizedFrame: CGRect = .zero
    
    // Defined Gradients
    let red = Gradient(colorTop: UIColor(red: 255/255, green: 152/255, blue: 152/255, alpha: 1.0), colorBottom: UIColor(red: 255/255, green: 139/255, blue: 139/255, alpha: 1.0))
    
    let blue = Gradient(colorTop: UIColor(red: 152/255, green: 234/255, blue: 255/255, alpha: 1.0), colorBottom: UIColor(red: 139/255, green: 205/255, blue: 255/255, alpha: 1.0))
    
    let yellow = Gradient(colorTop: UIColor(red: 254/255, green: 255/255, blue: 170/255, alpha: 1.0), colorBottom: UIColor(red: 251/255, green: 255/255, blue: 152/255, alpha: 1.0))

    let green = Gradient(colorTop: UIColor(red: 196/255, green: 255/255, blue: 152/255, alpha: 1.0), colorBottom: UIColor(red: 148/255, green: 255/255, blue: 139/255, alpha: 1.0))
    
    let orange = Gradient(colorTop: UIColor(red: 255/255, green: 229/255, blue: 152/255, alpha: 1.0), colorBottom: UIColor(red: 255/255, green: 214/255, blue: 139/255, alpha: 1.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
                
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
        
        // Set the scene to the view
        sceneView.scene = scene
        
        setupViews()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        
        sceneView.addGestureRecognizer(panGestureRecognizer)
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Setup Views
    func setupViews() {
        largePostItNote.alpha = 0
        largePostItNote.layer.cornerRadius = 8
        largePostItNote.isUserInteractionEnabled = false
        
        largePostItNoteEditStackView.alpha = 0
        largePostItNoteEditStackView.isUserInteractionEnabled = false
        
        workspaceIDBlurView.layer.cornerRadius = 8
        workspaceIDBlurView.layer.masksToBounds = true
        
        minimizedPostItNode.alpha = 0.0
        minimizedFrame = minimizedPostItNode.frame
        
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
        
        checkButton.layer.cornerRadius = checkButton.frame.height / 2
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        
        blueStickyNotes.layer.cornerRadius = 8
        greenStickyNoteButton.layer.cornerRadius = 8
        orangeStickyNoteBUtton.layer.cornerRadius = 8
        redStickyNoteButton.layer.cornerRadius = 8
        yellowStickyNoteButton.layer.cornerRadius = 8
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(SCNNode())
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first

        guard let foundGrid = grid else {
            return
        }

        foundGrid.update(anchor: planeAnchor)
    }
    
    // MARK: - Sticky Notes Clicked
    @IBAction func addBlueSticky(_ sender: Any) {
        openLargeNote(gradient: blue)
    }
    
    @IBAction func addGreenSticky(_ sender: Any) {
        openLargeNote(gradient: green)
    }
    
    @IBAction func addOrangeSticky(_ sender: Any) {
        openLargeNote(gradient: orange)
    }
    
    @IBAction func addRedSticky(_ sender: Any) {
        openLargeNote(gradient: red)
    }
    
    @IBAction func addYellowSticky(_ sender: Any) {
        openLargeNote(gradient: yellow)
    }
    
    @IBAction func hideLargeNote(_ sender: Any) {
        hideLargeNote()
    }
    
    @IBAction func acceptPostNote(_ sender: Any) {
        largePostItNoteEditStackView.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            self.largePostItNote.frame = self.minimizedPostItNode.frame
            let image = self.drawUIView(view: self.largePostItNote)
            
            self.currentImageView.image = image
            
            self.view.addSubview(self.currentImageView)

            self.currentImageView.frame = self.largePostItNote.frame
            
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                self.currentImageView.frame = self.minimizedPostItNode.frame
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            self.hideLargeNote()
        }
    }
    
    // MARK: - Large Note
    func openLargeNote(gradient: Gradient) {
        largePostItNote.backgroundColor = gradient.gl.colors?.first as! UIColor
        largePostItNote.layer.masksToBounds = true
        
        largePostItNoteEditStackView.isUserInteractionEnabled = true
        largePostItNote.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.largePostItNote.alpha = 1.0
            self.stickyNotesStackView.alpha = 0.0
            
            self.largePostItNoteEditStackView.alpha = 1.0
        }
    }
    
    func hideLargeNote() {
        largePostItNote.clearCanvasView()
        
        largePostItNoteEditStackView.isUserInteractionEnabled = false
        largePostItNote.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            self.largePostItNote.alpha = 0.0
            self.stickyNotesStackView.alpha = 1.0
           
            self.largePostItNoteEditStackView.alpha = 0.0
        }
    }
    
    @IBAction func leaveSession(_ sender: Any) {
        let alert = UIAlertController(title: "Would you like to leave this session?", message: "If you leave this session, you may not rejoin unless another user stays in the room. All your data will be saved under workspace ID: \(workspaceID)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Stay", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Tapped Screening
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)

        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)

        // Get hitTest results and ensure that the hitTest corresponds to a grid that has been placed on a wall
        guard let hitTest = hitTestResults.first, let anchor = hitTest.anchor as? ARPlaneAnchor else {
            return
        }
        
        DispatchQueue.main.async {
            self.addPainting(hitTest)
        }
    }
    
    
    // MARK: - Pan Gesture
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {

        gesture.minimumNumberOfTouches = 1

        let results = self.sceneView.hitTest(gesture.location(in: gesture.view), types: ARHitTestResult.ResultType.featurePoint)

        guard let result: ARHitTestResult = results.first else {
            return
        }

        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappedNode = hits.first?.node {
            let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            tappedNode.position = position
        }
    }
    
    func addPainting(_ hitResult: ARHitTestResult) {
        // 1.
        let plane = SCNPlane(width: 0.05, height: 0.05)
        plane.firstMaterial?.diffuse.contents = currentImageView.image
        currentImageView.removeFromSuperview()

        // 2.
        let paintingNode = SCNNode(geometry: plane)
        paintingNode.transform = SCNMatrix4(hitResult.anchor!.transform)
        paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y, paintingNode.eulerAngles.z)
        paintingNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(paintingNode)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Draw UIView to UIImage
    func drawUIView(view: CanvasView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
