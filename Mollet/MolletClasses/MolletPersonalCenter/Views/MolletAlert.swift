//
//  MolletAlert.swift
//  Mollet
//
//  Created by wml on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

typealias MolletAlertCallBack = (_ value: String) -> ()

class MolletAlert: UIView {
    
    let MolletToastShowAnimateDuration: TimeInterval = 0.25
    
    var cover: UIButton!
    var effectview: UIVisualEffectView!
    var isAlertShowCurrent: Bool!
    var alertCallBack: MolletAlertCallBack!
    
    
    class func alertWithName(name: String) -> Any {
        
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.last as Any
    }
    
    func set() {
        self.center = CGPoint.init(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT - self.frame.height - BottomBarH)
        self.backgroundColor = UIColor.clear
        
        self.cover = UIButton.init(type: .custom)
        cover.frame = UIScreen.main.bounds
        cover.backgroundColor = UIColor.black
        cover.addTarget(self, action: #selector(coverClick), for: .touchUpInside)
        cover.alpha = 0.0
        
    }
    
    class func show() {
        let alert = self.alertWithName(name: NSStringFromClass(self)) as? MolletAlert
        alert?.set()
        alert?.show()
        
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self.cover)
        
        self.center.y =  SCREEN_HEIGHT + self.frame.size.height/2
        window?.addSubview(self)
        
      UIView.animate(withDuration: MolletToastShowAnimateDuration, delay: 0, options: .curveEaseInOut, animations: {
        
            self.cover.alpha = 0.6
            self.center.y = SCREEN_HEIGHT - self.frame.size.height/2
            
        }) { (bool) in
            
        }
        
    }
    
    
    func dismiss() {
       
        UIView.animate(withDuration: MolletToastShowAnimateDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.cover.alpha = 0.0;
            self.center.y = SCREEN_HEIGHT + self.frame.size.height
            
        }) { (bool) in
            self.cover.removeFromSuperview()
            self.removeFromSuperview()
        }
        
        
    }
    
    
    @objc func coverClick() {
        dismiss()
    }
    
  

}
