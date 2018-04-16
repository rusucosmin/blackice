//
//  ViewController.swift
//  ArApp
//
//  Created by Sorin Sebastian Mircea on 08/04/2018.
//  Copyright © 2018 Sorin Sebastian Mircea. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSKViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var mapScaleSliderOutlet: UISlider!
    @IBOutlet weak var timelineSliderOutlet: UISlider!
    @IBOutlet weak var timelineLabelOutlet: UILabel!
    
    @IBOutlet weak var torontoLabelOutlet: UILabel!
    @IBOutlet weak var montrealLabelOutlet: UILabel!
    @IBOutlet weak var warningLabelOutlet: UILabel!
    
    
    var isMoving: Bool = false;
    var searchForHorizontalPlanes: Bool = false;
    var distanceToCamera: Float = -0.5;
    var mapPlaneNode: SCNNode = SCNNode();
    
    // Boxes
    var montrealBox: SCNNode?
    var torontoBox: SCNNode?
    var mediumBox: SCNNode?
    
    
    // CSV FILES
    var montrealCSV: [[String]] = [[]]
    var torontoCSV: [[String]] = [[]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add swipe gesture
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        self.sceneView.addGestureRecognizer(swipeGestureRecognizer)
        
        // Add long tap gesture
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTapped))
        longTapGestureRecognizer.minimumPressDuration = 1.0
        self.sceneView.addGestureRecognizer(longTapGestureRecognizer)
        
        // Make the scaleSlider Vertical
        mapScaleSliderOutlet.transform = CGAffineTransform( rotationAngle: CGFloat(Double.pi / 2) )
        mapScaleSliderOutlet.minimumValue = -2
        mapScaleSliderOutlet.maximumValue = -0.5
        
        // Add a plane
        mapPlaneNode = createPlane()
        
        // Add a box on the plane
//        let boxBottomLeft = createBox()
//        boxBottomLeft.position.x  = -0.2
//        boxBottomLeft.position.y  = -0.15
//        boxBottomLeft.position.z = 0
//        mapPlaneNode.addChildNode( boxBottomLeft )
//
//        let boxBottomRight = createBox()
//        boxBottomRight.position.x = 0.2
//        boxBottomRight.position.y = -0.15
//        boxBottomRight.position.z = 0
//        mapPlaneNode.addChildNode( boxBottomRight )
//
//        let boxTopLeft = createBox()
//        boxTopLeft.position.x = -0.2
//        boxTopLeft.position.y = 0.15
//        boxTopLeft.position.z = 0
//        mapPlaneNode.addChildNode( boxTopLeft )
//
//
//        let boxTopRight = createBox()
//        boxTopRight.position.x = 0.2
//        boxTopRight.position.y = 0.15
//        boxTopRight.position.z = 0.0
//        mapPlaneNode.addChildNode( boxTopRight )
        
        
        self.montrealBox = createBox(varname: 0.01)
        self.montrealBox!.position.x = 0.1018
        self.montrealBox!.position.y = -0.112
        self.montrealBox!.position.z = 0.0
        mapPlaneNode.addChildNode( self.montrealBox! )
        
        self.torontoBox = createBox(varname: 0.01)
        self.torontoBox!.position.x = 0.0858
        self.torontoBox!.position.y = -0.1202
        self.torontoBox!.position.z = 0.0
        mapPlaneNode.addChildNode( self.torontoBox! )
        
        sceneView.scene.rootNode.addChildNode( mapPlaneNode )
    
        self.mediumBox = createBox(varname: 0.005)
        self.mediumBox!.position.x = (self.montrealBox!.position.x + self.torontoBox!.position.x)/2
        self.mediumBox!.position.y = (self.montrealBox!.position.y + self.torontoBox!.position.y)/2
        self.mediumBox!.position.z = 0.0
        mapPlaneNode.addChildNode( self.mediumBox! )
        
        // READ CSV's
        self.montrealCSV = self.parseCSV(pathURL: "montreal")
        self.torontoCSV = self.parseCSV(pathURL:  "toronto")
        self.timelineSliderOutlet.minimumValue = 0
        self.timelineSliderOutlet.maximumValue = Float(self.montrealCSV.count) - 1.0
    }
    
    func readCSV(pathURL : String) -> [[String]] {
        let bundle = Bundle.main.path(forResource: pathURL, ofType: "csv")
    
        do {
            let content = try String(contentsOfFile:bundle!, encoding: String.Encoding.utf8)
            
            var lines: [[String]] = []
            content.enumerateLines { line, _ in
                lines.append( line.components(separatedBy: ",") )
            }
            
            return lines
        } catch  {
            
        }
        
        return []
    }
    
    func parseCSV(pathURL : String) -> [[String]] {
        var content = self.readCSV(pathURL: pathURL)
        return content
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        // Called when a tapp gesture is recognised
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        guard let hitResult = hitResults.first else { return }
        print(hitResults.count)
        if hitResult.node == mapPlaneNode {
            print("Tap Plane")
            isMoving = !isMoving
        }

    }
    
   @objc func swipe(recognizer :UITapGestureRecognizer) {
        print("Swipe")
        // Called when a swipe gesture is recognised
        searchForHorizontalPlanes = !searchForHorizontalPlanes
        if searchForHorizontalPlanes {
            print("swipe, searchForHorizontalPlanes = true")
        } else {
            print("swipe, searchForHorizontalPlanes = false")
        }
    }
    
    @objc func longTapped(recognizer :UITapGestureRecognizer) {
        if recognizer.state == .began {
            self.becomeFirstResponder()
            
            print("Long tap ended")
            // Called when a tapp gesture is recognised
            let sceneView = recognizer.view as! ARSCNView
            let touchLocation = recognizer.location(in: sceneView)
            let hitResults = sceneView.hitTest(touchLocation, options: [:])
            
            guard let hitResult = hitResults.first else { return }

            //mapPlaneNode.position = hitResult.node.childNodes.count
            print(hitResult.node.childNodes.count)
            print(hitResult.node.position)

            }
        }

    
    @IBAction func sliderAction(_ sender: UISlider) {
        // Set the LABEL to the selected date
        let pos : Int = Int(self.timelineSliderOutlet.value)
        self.timelineLabelOutlet.text = self.montrealCSV[pos][1]
        
        // Change the color of the boxes bases on the temperature (MONTREAL)
        var temperatureMontreal : Float = (self.montrealCSV[pos][2] as NSString).floatValue // kelvin
        self.setColorOf(boxInNode: self.montrealBox!, temperature: temperatureMontreal, label: self.montrealLabelOutlet, name: "Montreal")
        
        // Change the color of the boxes bases on the temperature (TORONTO)
        var temperatureToronto: Float = (self.torontoCSV[pos][2] as NSString).floatValue // kelvin
        self.setColorOf(boxInNode: self.torontoBox!, temperature: temperatureToronto, label: self.torontoLabelOutlet, name: "Toronto")
    
        // Change color of MEDIUM
        var temperatureMedium: Float = (temperatureToronto + temperatureMontreal) / 2
        self.setColorOf(boxInNode: self.mediumBox!, temperature: temperatureMedium, label: UILabel(), name: "")
        
        if( temperatureMedium - 273.15 <= 0.3 ) {
            warningLabelOutlet.isHidden = false
            warningLabelOutlet.text = "🚨 Black ice ALERT 🚨"
        } else {
            warningLabelOutlet.isHidden = true
        }
        print(temperatureMontreal)
        print(temperatureMedium)
        print(temperatureToronto)
        
        print("\n\n")
    }
    
    func setColorOf( boxInNode : SCNNode, temperature : Float, label : UILabel, name : String ) {
        
        // COLOR OF THE BOX
        let material = SCNMaterial()
        if temperature >= 273.15 {
            //       273.15   => 310
            // step 1:     0  => 36.85
            // step 2:     0  => 1
            var red = max(0.5, ( CGFloat(temperature) - 273.15 ) / 36.85)
            boxInNode.geometry!.materials = [material]
            material.diffuse.contents = UIColor(red: red, green: 0.0, blue: 0.0, alpha: 1.0)
            
            label.text = "☀️ " + name + ": " + String(format: "%.2f ℃", temperature - 273.15)
        } else {
            //    250            => 273.15
            // step1:    0       => 23.15
            // step1: 0 => 1
            var blue = (CGFloat(temperature) - 250) / 23.15
            material.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: blue, alpha: 1.0)
            boxInNode.geometry!.materials = [material]
            
            label.text = "❄️ " + name + ": " + String(format: "%.2f ℃", temperature - 273.15)
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if isMoving {
            DispatchQueue.main.async {
                self.mapScaleSliderOutlet.isHidden = false
            }
            
            // Move map plane to a new position
            var newPos = simd_mul( sceneView.pointOfView!.simdTransform, simd_float4(0.0, 0.0, distanceToCamera, 1.0))
            mapPlaneNode.position = SCNVector3(newPos.x, newPos.y, newPos.z)
            mapPlaneNode.simdRotation = sceneView.pointOfView!.simdRotation
        } else {
            DispatchQueue.main.async {
                self.mapScaleSliderOutlet.isHidden = true
            }
        }
    }
    
    @IBAction func mapScaleSlider(_ sender: UISlider) {
        distanceToCamera = sender.value
        print(sender.value)
    }
    
    
    
    func createBox(varname : CGFloat) -> SCNNode {
        // Create the box
        let box = SCNBox(width: varname, height: varname, length: varname, chamferRadius: 0.5)
        
        // Create a material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]
        
        // Create the node that contains the box
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, -0.5) // => will follow the camera
        
        return boxNode
    }
    
    func createPlane() -> SCNNode {
        // Get the image
        let image = UIImage(named: "art.scnassets/canada.png")!
        
        // Create the plane
        let plane = SCNPlane(width: 0.4, height: 0.3)
        plane.name = "mapPlane"
        
        // Create a material
        let material = SCNMaterial()
        material.diffuse.contents = image
        plane.materials = [material]
        
        // Create the node that contains the box
        let boxNode = SCNNode(geometry: plane)
        boxNode.position = SCNVector3(0, 0, -0.5) // => will follow the camera
        boxNode.name = "mapPlane"
        
        return boxNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable finding horizontalp planes
        configuration.planeDetection = .horizontal
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    //
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // 1
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        // 2
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//
//        // 3
//        mapPlaneNode.position = SCNVector3(x,y,z)
        
        // 1
        if(searchForHorizontalPlanes) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            // 2
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            // 3
            plane.materials.first?.diffuse.contents = UIColor.blue
            plane.materials.first?.transparency = 0.5
            
            // 4
            var planeNode = SCNNode(geometry: plane)
            
            // 5
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.name = "auxPlane"
            planeNode.eulerAngles.x = -.pi / 2
            
            // 6
            node.addChildNode(planeNode)
        }
       
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height

        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    
}




