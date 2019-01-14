//
//  MolletBodyWeightAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletBodyWeightAlert: MolletAlert {

    @IBOutlet weak var bodyWeightTF: UITextField!
    

    class func showWithCallBack(callBack: @escaping MolletAlertCallBack ) {
        
     let bodyWeightAlert = self.alertWithName(name: "MolletBodyWeightAlert") as! MolletBodyWeightAlert
        bodyWeightAlert.frame.size.width = SCREEN_WIDTH;
        bodyWeightAlert.set()
        bodyWeightAlert.show()
        bodyWeightAlert.alertCallBack = callBack
        bodyWeightAlert.backgroundColor = UIColor.white
        bodyWeightAlert.bodyWeightTF.becomeFirstResponder()

    }

    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss()
        self.bodyWeightTF.text = "";
    }
    
    
    @IBAction func okAction(_ sender: UIButton) {
        if (self.alertCallBack != nil) {
            let value = self.bodyWeightTF.text ?? ""
            self.alertCallBack(value)
        }
        self.dismiss()
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
    }
    
    
}
