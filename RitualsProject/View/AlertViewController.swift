//
//  AddDetailController.swift
//  RitualsTask
//
//  Created by Goldmedal on 29/01/24.
//

import UIKit
import Foundation

protocol AlertViewDelegate{
    func pinDetails(pinName:String,locationName:String,pinType:String)
}

class AlertViewController: UIViewController {
    @IBOutlet var pinNameEntered: UITextField!
    @IBOutlet var menuButtonPressed: UIButton!
    @IBOutlet var locationNameEntered: UITextField!
    @IBOutlet var addPressedButton: UIButton!
    @IBOutlet var cancelPressedButton: UIButton!
    
    var delegate: AlertViewDelegate?
    var pinId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButtonPressed.menu = addMenuItems()
        addPressedButton.layer.cornerRadius = 5
        cancelPressedButton.layer.cornerRadius = 5
    }
    
    func addMenuItems() -> UIMenu{
        let menuItems = UIMenu(title:"",options: .displayInline,children:[
            UIAction(title:"Amenities",state: .off,handler: {(action) in
                self.menuButtonPressed.setTitle("Amenities", for: .normal)
                self.pinId = "1"
            }),
            UIAction(title:"Events",state: .off,handler: {(action) in
                self.menuButtonPressed.setTitle("Events", for: .normal)
                self.pinId = "1"
            }),
        ])
        return menuItems
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        let newPinName = pinNameEntered.text!
        let newLocationName = locationNameEntered.text!
        let newPinType = menuButtonPressed.currentTitle!
 
        if newPinName != "" && newPinType != "" && newLocationName != ""{
            self.delegate?.pinDetails(pinName: newPinName, locationName: newLocationName,pinType: newPinType)
            let successAlert = UIAlertController(title: "Success", message: "Successfully added new details", preferredStyle: UIAlertController.Style.alert)
            let successAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            })
            successAlert.addAction(successAction)
            self.present(successAlert, animated: true)
        }
        else{
            let errorAlert = UIAlertController(title: "Warning", message: "Please fill all the details.", preferredStyle: UIAlertController.Style.alert)
            let errorAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            errorAlert.addAction(errorAction)
            self.present(errorAlert, animated: true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
