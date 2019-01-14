//
//  MolletChoosePhotoAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletChoosePhotoAlert: MolletAlert {
    

    class func showWithCallBack(callBack: @escaping MolletAlertCallBack ) {
        
        let sizeAlert = self.alertWithName(name: "MolletChoosePhotoAlert") as! MolletChoosePhotoAlert
        sizeAlert.frame.size.width = SCREEN_WIDTH;
        sizeAlert.set()
        sizeAlert.show()
        sizeAlert.alertCallBack = callBack
        sizeAlert.backgroundColor = UIColor.white
    }


    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dismiss()
        
    }
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        
        YBUploadImageManager.manager.createPhotoView()
        self.dismiss()
        
    }
    
    
    @IBAction func choosePhotoFromAlbum(_ sender: UIButton) {
        
        YBUploadImageManager.manager.selectImageFromPhotoLibrary()
        self.dismiss()
        
    }
    
    
    
}
