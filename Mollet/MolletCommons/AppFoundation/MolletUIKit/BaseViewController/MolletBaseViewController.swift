//
//  MolletBaseViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import Reachability

class MolletBaseViewController: UIViewController {
    
    var navTitle:String = "" {
        didSet{
            titleLab.text = navTitle
        }
    }
    var titleLab:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置title
        titleLab = UILabel.init(frame: MRect(x: 0, y: 0, width: 150, height: 44))
        titleLab.font = UIFont.systemFont(ofSize: 20)
        titleLab.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLab
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.setBackButton()
        }
        //网络监听
        ReachabilityManager.netWorkCheck()
    }
    
    func setBackButton() {
        //设置返回按钮
        let leftView = UIButton.init(frame: MRect(x: 10, y: 0, width: 50, height: 50))
        leftView.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
        let backBarItem = UIBarButtonItem.init(customView: leftView)
        self.navigationItem.leftBarButtonItem = backBarItem
        _ = leftView.rx.tap.subscribe(onNext:{
            self.navigationController?.popViewController(animated: true)
        })
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
