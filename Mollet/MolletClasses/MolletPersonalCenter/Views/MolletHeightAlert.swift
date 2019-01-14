//
//  MolletHeightAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletHeightAlert: MolletAlert {

    @IBOutlet weak var molletHieghtTextField: UITextField!
    
    class func showWithCallBack(callBack: @escaping MolletAlertCallBack ) {
        
        let heightAlert = self.alertWithName(name: "MolletHeightAlert") as! MolletHeightAlert
        heightAlert.frame.size.width = SCREEN_WIDTH;
        heightAlert.set()
        heightAlert.show()
        heightAlert.alertCallBack = callBack
        heightAlert.backgroundColor = UIColor.white
        heightAlert.molletHieghtTextField.becomeFirstResponder()
    }

    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss()
    }
    
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if self.alertCallBack != nil {
            let heightValue = self.molletHieghtTextField.text
            self.alertCallBack(heightValue ?? "")
        }
         self.dismiss()
    }
    
    
}
