//
//  MolletNavigationController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletNavigationController: UINavigationController {
    
    var customBackBar:UIBarButtonItem!
    var titleLab:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle()
    }
    
    func setNavigationBarStyle() {
        //设置导航颜色
        let image = imageFromColor(color: ColorFromRGBA(r: 255, g: 255, b: 255, a: 1))
        self.navigationBar.setBackgroundImage(image, for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        //隐藏导航底部的黑线
        self.navigationBar.shadowImage = UIImage()
       
    }
    
    @objc func backAction () {
        
    }
    
    //颜色->图片
    func imageFromColor(color: UIColor) -> UIImage {
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsGetCurrentContext()
        
        return image!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MolletNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count <= 1 {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
