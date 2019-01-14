
//
//  MolletRegistNameViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletRegistNameViewController: UIViewController ,DateViewDelegate, UIAlertViewDelegate{

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var birthdayBtn: UIButton!
    @IBOutlet weak var birthdayLab: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    
    var dateView:DateView!
    var viewModel:MolletRegistViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func bindViewModel() {
        
        //绑定VM
        _ = self.nameTf.rx.textInput <-> viewModel.name
        _ = viewModel.birthday.asObservable().bind(to: self.birthdayLab.rx.text)
        
        _ = self.birthdayBtn.rx.tap.subscribe(onNext:{ [weak self] in
            self?.view.endEditing(true)
            self?.dateView.showDatePicker(showTime: false)
        })
        
        _ = self.backButton.rx.tap.subscribe(onNext:{
            let alert = UIAlertView.init(title: "Warning!", message: "Please fill in the full information!", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Confirm")
            alert.show()
        })
        
        //注册下一步
        _ = self.nextButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .withLatestFrom(self.viewModel.birthdayVaild)
            .filter({ vaild in
                if vaild == false {
                    print("请输入完整信息")
                    self.noticeOnlyText("Please fill in the full information!")
                }
                return vaild
            })
            .subscribe(onNext:{_ in
                let registGenderVC = MolletRegistGenderViewController()
                registGenderVC.viewModel = self.viewModel
                self.navigationController?.pushViewController(registGenderVC, animated: true)
            })
    }

    func setupSubviews() {
        
        //展示日期显示
        dateView = DateView.init(frame: CGRect.zero)
        dateView.delegate = self
        self.view.addSubview(dateView)
    }
    
    //dateView 代理
    func selectDateString(dateString: String, timestamp: Double) {
        self.birthdayLab.text = dateString
        viewModel.birthday.value = dateString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //用户直接返回
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
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
