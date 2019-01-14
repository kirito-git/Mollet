//
//  MolletNameAlert.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/10/9.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletNameAlert: MolletAlert {

    @IBOutlet weak var nameTf: UITextField!

    class func showWithCallBack(callBack: @escaping MolletAlertCallBack ) {
        
        let nameAlert = self.alertWithName(name: "MolletNameAlert") as! MolletNameAlert
        nameAlert.frame.size.width = SCREEN_WIDTH
        nameAlert.set()
        nameAlert.show()
        nameAlert.alertCallBack = callBack
        nameAlert.backgroundColor = UIColor.white
        nameAlert.nameTf.becomeFirstResponder()
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss()
    }
    
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if self.alertCallBack != nil {
            let nameValue = self.nameTf.text
            self.alertCallBack(nameValue ?? "")
        }
        self.dismiss()
    }

}
