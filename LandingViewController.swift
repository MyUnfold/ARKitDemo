//
//  LandingViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 01/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var numberOfItemsTextField: UITextField!
    
    @IBOutlet weak var configurationTextField: UITextField!
    private let pickerView = UIPickerView()
    
    private let configurations = ["Center", "Corner 0", "Corner 1", "Corner 2", "Corner 3", "Side 0", "Side 1", "Side 2", "Side 3"]
    
    var length : CGFloat = 0.0
    var width : CGFloat = 0.0
    var numberOfImages : CGFloat = 0.0
    var pickerConfigurationIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        lengthTextField.delegate = self
        widthTextField.delegate = self
        numberOfItemsTextField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        configurationTextField.inputView = pickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == lengthTextField {
            if let n = NumberFormatter().number(from: lengthTextField.text ?? "") {
                length = CGFloat(n)
            }
        }
        
        if textField == widthTextField {
            if let n = NumberFormatter().number(from: widthTextField.text ?? "") {
                width = CGFloat(n)
            }
        }
        
        if textField == numberOfItemsTextField {
            if let n = NumberFormatter().number(from: numberOfItemsTextField.text ?? "") {
                numberOfImages = CGFloat(n)
            }
        }
        
        return true
    }
    
    
    @IBAction func pushToNext(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPark", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let n1 = NumberFormatter().number(from: lengthTextField.text ?? "") {
            length = CGFloat(n1)
        }
        if let n2 = NumberFormatter().number(from: widthTextField.text ?? "") {
            width = CGFloat(n2)
        }
        if let n3 = NumberFormatter().number(from: numberOfItemsTextField.text ?? "") {
            numberOfImages = CGFloat(n3)
        }
        if length == 0 || width == 0 || numberOfImages == 0 {
            return
        }
        
        if let destination = segue.destination as? GoParkViewController {
            destination.length = self.length
            destination.width = self.width
            destination.numberOfImages = self.numberOfImages
            destination.configurationPicked = self.pickerConfigurationIndex
        }
    }
    
}

extension LandingViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        configurations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        configurations[row]
    }
    
}

extension LandingViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerConfigurationIndex = row
        configurationTextField.text = configurations[row]
    }
}
