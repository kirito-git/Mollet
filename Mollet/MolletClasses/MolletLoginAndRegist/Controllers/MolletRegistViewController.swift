//
//  MolletRegistViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletRegistViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var pwdTf: UITextField!
    @IBOutlet weak var repwdTf: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    
    var viewModel:MolletRegistViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupSubviews()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel = MolletRegistViewModel()
        
        _ = self.emailTf.rx.textInput <-> viewModel.email
        _ = self.pwdTf.rx.textInput <-> viewModel.pwd
        _ = self.repwdTf.rx.textInput <-> viewModel.rePwd
        
        _ = self.backButton.rx.tap.subscribe(onNext:{
            self.navigationController?.popViewController(animated: true)
        })
        
        //注册点击
        _ = self.nextButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .withLatestFrom(self.viewModel.accountVaild)
            .filter({ vaild in
                if vaild == false {
                    print("请输入完整信息")
                    self.noticeOnlyText("Please enter more than six account and password!")
                }
                return vaild
            })
            .flatMap{_ in
                self.viewModel.rePwdVaild()
            }
            .filter({ vaild in
                if vaild == false {
                    //不一致 提示
                    print("密码为空或者不一致")
                    self.noticeOnlyText("Inconsistent password!")
                }
                return vaild
            })
            .flatMapLatest{ _ in self.viewModel.registRequest() }
            .subscribe(onNext:{ [weak self] response in
                self?.noticeOnlyText("Registered successfully!")
                let registNameVC = MolletRegistNameViewController()
                registNameVC.viewModel = self?.viewModel
                self?.navigationController?.pushViewController(registNameVC, animated: true)
            })
    }
    
    func setupSubviews() {
        self.agreeBtn.setImage(UIImage.init(named: "agree-normal"), for: .normal)
        self.agreeBtn.setImage(UIImage.init(named: "agree-select"), for: .selected)
    }

    @IBAction func privacyPolicyClick(_ sender: Any) {
        self.present(PrivacyPolicyViewController(), animated: true, completion: nil)
    }
    
    @IBAction func agreeBtnSelect(_ sender: UIButton) {
        let isselect = !sender.isSelected
        self.viewModel.isAgree.value = isselect
        print(isselect)
        sender.isSelected = isselect
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
