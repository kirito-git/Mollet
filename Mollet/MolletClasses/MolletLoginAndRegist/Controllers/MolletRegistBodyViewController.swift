//
//  MolletRegistBodyViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/27.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletRegistBodyViewController: UIViewController {

    var viewModel:MolletRegistViewModel!
    
    @IBOutlet weak var heightTf: UITextField!
    @IBOutlet weak var weightTf: UITextField!
    @IBOutlet weak var sizeBTf: UITextField!
    @IBOutlet weak var sizeWTf: UITextField!
    @IBOutlet weak var sizeHTf: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    func bindViewModel() {
        
//        _ = self.heightTf.rx.textInput <-> viewModel.height
//        _ = self.weightTf.rx.textInput <-> viewModel.weight
        _ = self.sizeBTf.rx.textInput <-> viewModel.sizeB
        _ = self.sizeWTf.rx.textInput <-> viewModel.sizeW
        _ = self.sizeHTf.rx.textInput <-> viewModel.sizeH
        
        _ = self.viewModel.height.asObservable().map{"\($0)cm"}.bind(to: self.heightTf.rx.text)
        _ = self.viewModel.weight.asObservable().map{"\($0)kg"}.bind(to: self.weightTf.rx.text)
        
        //下一步点击
        _ = self.nextButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .withLatestFrom(self.viewModel.bodyVaild)
            .filter({ vaild in
                if vaild == false {
                    self.noticeOnlyText("Please fill in the full information!")
                }
                return vaild
            })
            .flatMapLatest{ _ in self.viewModel.setUserInfoRequest() }
            .subscribe(onNext:{ _ in
                //完善资料返回结果
                self.noticeOnlyText("Filled in successfully!")
                //延时两秒
                _ = Observable.of(0)
                .delay(2, scheduler: MainScheduler.instance)
                .subscribe(onNext:{ _ in
                    self.navigationController?.popToRootViewController(animated: true)
                    //发送通知 自动登录
                    self.sendAutoLoginNotification()
                })
            })
        
        //跳过 仍然请求除了个人资料更新之外的信息
        _ = self.skipButton.rx.tap
            .subscribe(onNext:{
                self.present(MolletTools.alertController(msg: "Skip body data input?", {
                    _ = self.viewModel.setUserInfoWithoutBodyRequest()
                        .subscribe(onNext:{ _ in
                            //完善资料
                            self.noticeOnlyText("Login...")
                            //延时两秒
                            _ = Observable.of(0)
                                .delay(2, scheduler: MainScheduler.instance)
                                .subscribe(onNext:{ _ in
                                    self.navigationController?.popToRootViewController(animated: true)
                                    //发送通知 自动登录
                                    self.sendAutoLoginNotification()
                                })
                        })
                }), animated: true, completion: nil)
            })
        
        //返回
        _ =  self.backButton.rx.tap
            .subscribe(onNext:{
                self.navigationController?.popViewController(animated: true)
            })
    }
    
    func sendAutoLoginNotification() {
        //发送通知 自动登录
        let dic = [
            "email": self.viewModel.email.value,
            "pwd": self.viewModel.pwd.value
        ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AutoLoginNotification), object: self, userInfo: dic)
    }
    
    @IBAction func heightClick(_ sender: Any) {
        MolletHeightAlert.showWithCallBack { (heightValue) in
            print(heightValue)
            if (heightValue.count > 0) {
                self.viewModel.height.value = heightValue
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
    @IBAction func weightClick(_ sender: Any) {
        MolletBodyWeightAlert.showWithCallBack { (value) in
            if (value.count > 0) {
                self.viewModel.weight.value = value
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
    @IBAction func sizeClick(_ sender: Any) {
        MolletSizeAlert.showWithCallBack { (bustValue, waistValue, hips) in
            if (bustValue.count > 0 && waistValue.count > 0 && hips.count > 0) {
                self.viewModel.sizeB.value = bustValue
                self.viewModel.sizeW.value = waistValue
                self.viewModel.sizeH.value = hips
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
