//
//  MolletForgetPasswordViewController.swift
//  Mollet
//
//  Created by wml on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var codeTf: UITextField!
    @IBOutlet weak var pwdTf: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var countDownButton: YBCountDownButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel:MolletForgetPasswordViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func setupSubviews() {
        countDownButton.layer.cornerRadius = 10
        countDownButton.layer.masksToBounds = true
        countDownButton.titleLabel?.font = MFontWithSize(size: Float(ScaleWidth(value: 12)))
    }
    
    func bindViewModel() {
        viewModel = MolletForgetPasswordViewModel()
        
        _ = self.emailTf.rx.textInput <-> viewModel.email
        _ = self.codeTf.rx.textInput <-> viewModel.code
        _ = self.pwdTf.rx.textInput <-> viewModel.pwd
        
        _ = self.backButton.rx.tap.subscribe(onNext:{
            self.navigationController?.popViewController(animated: true)
        })
        
        _ = self.countDownButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .withLatestFrom(self.viewModel.sendCodeVaild)
            .filter({ vaild in
                if vaild == false {
                    self.noticeOnlyText("Please fill in the email!")
                }
                return vaild
            })
            .flatMapLatest{ _ in self.viewModel.sendCodeRequest()}
            .subscribe(onNext:{ [weak self] _ in
                self?.countDownButton.start()
            })
        
        _ = self.nextButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .withLatestFrom(self.viewModel.inputVaild)
            .filter({ vaild in
                if vaild == false {
                    self.noticeOnlyText("Please fill in the full information!")
                }
                return vaild
            })
            //.flatMapLatest{}
            .subscribe(onNext:{ _ in
                //设置密码
                self.noticeOnlyText("Update completed, going to log in ...")
                //延时两秒
                _ = Observable.of(0)
                    .delay(1, scheduler: MainScheduler.instance)
                    .subscribe(onNext:{ _ in
                        self.navigationController?.popToRootViewController(animated: true)
                        //发送通知 自动登录
                        //self.sendAutoLoginNotification()
                    })
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
