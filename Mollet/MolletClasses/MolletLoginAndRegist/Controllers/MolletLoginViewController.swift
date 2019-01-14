//
//  MolletLoginViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MolletLoginViewController: MolletBaseViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    
    @IBOutlet weak var logoImgvi: UIImageView!
    @IBOutlet weak var emailLogo: UIImageView!
    
    var viewModel = MolletLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func setupSubviews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.logoImgvi.snp.makeConstraints { (make) in
            make.top.equalTo(ScaleWidth(value: 95))
        }
        self.emailLogo.snp.makeConstraints { (make) in
            make.top.equalTo(self.logoImgvi.snp.bottom).offset(ScaleWidth(value: 66))
        }
    }
    
    func bindViewModel() {
        
        _ = self.email.rx.textInput <-> viewModel.email
        _ = self.password.rx.textInput <-> viewModel.passWord
        
        //登录点击
        _ = self.signInButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            //startWith 会先调用一次点击
//            .startWith(MBProgressHUDSwift.showLoading())
            .withLatestFrom(self.viewModel.inputVaild)
            .filter({ vaild in
                if vaild == false {
                    print("请输入账号或密码")
                    self.noticeOnlyText("Please fill in the account and password!")
                }
                return vaild
            })
            .flatMapLatest{_ in
                self.viewModel.login()
            }
            .subscribe(onNext: { (response) in
                self.noticeOnlyText("Login successfully!")
                self.viewModel.getLoginMsg()
                self.viewModel.saveGlobalData()
                self.navigationController?.dismiss(animated: true, completion: nil)
                //登录成功
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshContractListNotification), object: nil)
            }).addDisposableTo(disposebag)
        
        
        //注册
        _ = self.signupButton.rx.tap
            .subscribe(onNext:{
            self.navigationController?.pushViewController(MolletRegistViewController(), animated: true)
        })
        
        //忘记密码
        _ = self.forgetButton.rx.tap
            .subscribe(onNext:{
                self.navigationController?.pushViewController(MolletForgetPasswordViewController(), animated: true)
            })
        
        //注册完成自动登录 账号和密码传过来
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(AutoLoginNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{[weak self] notification in
                //获取通知数据
                let userInfo = notification.userInfo as! [String: AnyObject]
                let value1 = userInfo["email"] as! String
                let value2 = userInfo["pwd"] as! String
                print(value1)
                print(value2)
                self?.viewModel.email.value = value1
                self?.viewModel.passWord.value = value2
                _ = self?.viewModel.login()
                    .subscribe(onNext:{(response) in
                        self?.noticeOnlyText("Login successfully!")
                        self?.viewModel.getLoginMsg()
                        self?.viewModel.saveGlobalData()
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                        //登录成功
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshContractListNotification), object: nil)
                    })
            })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
