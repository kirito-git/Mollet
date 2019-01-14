//
//  MolletPersonalCenterViewController.swift
//  Mollet
//
//  Created by wml on 2018/9/14.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletPersonalCenterViewController: MolletBaseViewController {

    @IBOutlet weak var genderImgvi: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var avatarImgVi: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var countryTf: UITextField!
    @IBOutlet weak var birthdayTf: UITextField!
    @IBOutlet weak var weightLab: UILabel!
    @IBOutlet weak var heightLab: UILabel!
    @IBOutlet weak var sizeBLab: UILabel!
    @IBOutlet weak var sizeWLab: UILabel!
    @IBOutlet weak var sizeHLab: UILabel!
    @IBOutlet weak var phoneLab: UILabel!
    
    
    @IBOutlet weak var logout: UIButton!
    
    var viewModel:MolletPersonalCenterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel = MolletPersonalCenterViewModel()
        
        _ = viewModel.name.asObservable().bind(to: self.nameLab.rx.text)
        self.avatarImgVi.sd_setImage(with: URL(string: viewModel.profileUrl.value), placeholderImage: UIImage(named: "head-placeholder"))
        self.viewModel.profileImage = self.avatarImgVi.image
        _ = self.viewModel.gender.asObservable().subscribe(onNext:{ value in
            self.genderImgvi.image = UIImage.init(named: value)
        })
        _ = self.countryTf.rx.textInput <-> viewModel.country
        _ = self.birthdayTf.rx.textInput <-> viewModel.birthday
        _ = viewModel.weight.asObservable().map{"\($0)kg"}.bind(to: self.weightLab.rx.text)
        _ = viewModel.height.asObservable().map{"\($0)cm"}.bind(to: self.heightLab.rx.text)
        _ = viewModel.sizeB.asObservable().map{"\($0)cm"}.bind(to: self.sizeBLab.rx.text)
        _ = viewModel.sizeW.asObservable().map{"\($0)cm"}.bind(to: self.sizeWLab.rx.text)
        _ = viewModel.sizeH.asObservable().map{"\($0)cm"}.bind(to: self.sizeHLab.rx.text)
        _ = viewModel.phone.asObservable().bind(to: self.phoneLab.rx.text)
        
        //退出登录
        _ = self.logout.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .subscribe(onNext:{
                
                self.present(MolletTools.alertController(msg: "Confirm log out ?", {
                    
                    self.viewModel.logout()
                    self.viewModel.getUserInfoFromUserDefault()
                    MBProgressHUDSwift.dismiss()
                    
                    //跳转登录页
                    self.navigationController?.popViewController(animated: false)
                    NotificationCenter.default.post(name: Notification.Name(rawValue:GotoLoginViewControllerNotification), object: nil)
                }), animated: true, completion: nil)
                
            })
        
        //登录后更新用户信息
//        _ = NotificationCenter.default.rx
//            .notification(NSNotification.Name(rawValue: UserInfoDidFetchNotification))
//            .takeUntil(self.rx.deallocated)
//            .subscribe(onNext:{_ in
//                self.viewModel.getUserInfoFromUserDefault()
//            })
    }
    
    func setupSubviews() {
        self.avatarImgVi.layer.cornerRadius = 45
        self.avatarImgVi.layer.masksToBounds = true
        
        self.shadowView.layer.cornerRadius = 45
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOffset = CGSize(width:0,height:5)
        self.shadowView.layer.shadowOpacity = 0.3
    }

    //改变头像
    @IBAction func changeAvatarAction(_ sender: UIButton) {
        
        MolletChoosePhotoAlert.showWithCallBack { (image) in
        }
        YBUploadImageManager.manager.fatherViewController = self;
        YBUploadImageManager.manager.uploadImageClourse = { (image, _) in
            //将image转换成base64字符串
            //self.viewModel.profileImage = image
            let tuple = MolletTools.base64StringFromImage(image: image)
            let imageBase64Str = tuple.0
            self.viewModel.profileImage = tuple.1
            
            _ = self.viewModel.updateUserInfo(replaceDic: ["ProfilePicData":imageBase64Str])
                .loadingPlugin()
                .subscribe(onNext:{ _ in
                    self.avatarImgVi.image = tuple.1
                    self.noticeOnlyText("Update completed!")
                    self.viewModel.saveUserAvatar()
                })
        }
    }
   
   //编辑名字
    @IBAction func editNameAction(_ sender: UIButton) {
        MolletNameAlert.showWithCallBack { (value) in
            if (value.count > 0) {
                self.viewModel.name.value = value
                _ = self.viewModel.updateUserInfo(replaceDic: ["FullName":value])
                    .loadingPlugin()
                    .subscribe(onNext:{ _ in
                        self.noticeOnlyText("Update completed!")
                        self.viewModel.saveUserInfo(replaceDic: ["FullName":value])
                    })
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
    //编辑体重
    @IBAction func editWeightAction(_ sender: UITapGestureRecognizer) {

        MolletBodyWeightAlert.showWithCallBack { (value) in
            if (value.count > 0) {
                self.viewModel.weight.value = value
                _ = self.viewModel.updateUserInfo(replaceDic: ["Weight":value])
                    .loadingPlugin()
                    .subscribe(onNext:{ _ in
                        self.noticeOnlyText("Update completed!")
                        self.viewModel.saveUserInfo(replaceDic: ["Weight":value])
                    })
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
   
    //编辑身高
    @IBAction func editHeightAction(_ sender: UITapGestureRecognizer) {
       
        MolletHeightAlert.showWithCallBack { (heightValue) in
            if (heightValue.count > 0) {
                self.viewModel.height.value = heightValue
                _ = self.viewModel.updateUserInfo(replaceDic: ["Height":heightValue])
                    .loadingPlugin()
                    .subscribe(onNext:{ _ in
                        self.noticeOnlyText("Update completed!")
                        self.viewModel.saveUserInfo(replaceDic: ["Height":heightValue])
                    })
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
    //编辑三围
    @IBAction func editMeasurementAction(_ sender: UITapGestureRecognizer) {
        
        MolletSizeAlert.showWithCallBack { (bustValue, waistValue, hips) in
            if (bustValue.count > 0 && waistValue.count > 0 && hips.count > 0) {
                self.viewModel.sizeB.value = bustValue
                self.viewModel.sizeW.value = waistValue
                self.viewModel.sizeH.value = hips
                _ = self.viewModel.updateUserInfo(replaceDic: ["Waist":waistValue,"Bust": bustValue,"Hips": hips])
                    .loadingPlugin()
                    .subscribe(onNext:{ _ in
                        self.noticeOnlyText("Update completed!")
                        self.viewModel.saveUserInfo(replaceDic: ["Waist":waistValue,"Bust": bustValue,"Hips": hips])
                    })
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
    }
    
   //编辑手机号码
    @IBAction func editPhoneNumberAction(_ sender: UITapGestureRecognizer) {
        
        MolletPhoneNumberAlert.showWithCallBack { (value) in
            if (value.count > 0) {
                self.viewModel.phone.value = value
                _ = self.viewModel.updateUserInfo(replaceDic: ["PhoneNumber":value])
                    .loadingPlugin()
                    .subscribe(onNext:{ _ in
                        self.noticeOnlyText("Update completed!")
                        self.viewModel.saveUserInfo(replaceDic: ["PhoneNumber":value])
                    })
            }else {
                self.noticeOnlyText("Can not be empty!")
            }
        }
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
