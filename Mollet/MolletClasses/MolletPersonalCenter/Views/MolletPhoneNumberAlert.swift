//
//  MolletPhoneNumberAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit


class MolletPhoneNumberAlert: MolletAlert {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    class func showWithCallBack(callBack: @escaping MolletAlertCallBack ) {
        
        let phoneNumberAlert = self.alertWithName(name: "MolletPhoneNumberAlert") as! MolletPhoneNumberAlert
        phoneNumberAlert.frame.size.width = SCREEN_WIDTH;
        phoneNumberAlert.set()
        phoneNumberAlert.show()
        phoneNumberAlert.alertCallBack = callBack
        phoneNumberAlert.backgroundColor = UIColor.white
        phoneNumberAlert.phoneNumberTextField.becomeFirstResponder()

    }

    @IBAction func cancelChooseAction(_ sender: UIButton) {
        self.dismiss()
        self.phoneNumberTextField.text = "";
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        if (self.alertCallBack != nil) {
            let value = self.phoneNumberTextField.text ?? ""
            self.alertCallBack(value)
        }
        self.dismiss()
    }
    
}
