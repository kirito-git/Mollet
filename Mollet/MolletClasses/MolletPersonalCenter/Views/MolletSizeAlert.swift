//
//  MolletSizeAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit


typealias MolletSizeAlertClourse = (_ bustValue: String, _ waistValue: String, _ hipsValue: String) -> Void

class MolletSizeAlert: MolletAlert {
    
    var molletSizeClourse: MolletSizeAlertClourse!
    
    @IBOutlet weak var bustTextField: UITextField!
    
    @IBOutlet weak var waistTextField: UITextField!
    
    @IBOutlet weak var hipsTextField: UITextField!
    
    class func showWithCallBack(callBack: @escaping MolletSizeAlertClourse ) {
        
      let sizeAlert = self.alertWithName(name: "MolletSizeAlert") as! MolletSizeAlert
        sizeAlert.frame.size.width = SCREEN_WIDTH;
        sizeAlert.set()
        sizeAlert.show()
        sizeAlert.molletSizeClourse = callBack
        sizeAlert.backgroundColor = UIColor.white
        sizeAlert.bustTextField.becomeFirstResponder()
    }

    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.bustTextField.text = ""
        self.waistTextField.text = ""
        self.hipsTextField.text = ""
        self.dismiss()
        
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if (self.molletSizeClourse != nil) {
            
            let bustValue = self.bustTextField.text
            let waistValue = self.waistTextField.text
            let hipsValue = self.hipsTextField.text
            
            self.molletSizeClourse(bustValue ?? "", waistValue ?? "", hipsValue ?? "")
        }
        self.dismiss()
        
    }
    
    
    
    
    

}
