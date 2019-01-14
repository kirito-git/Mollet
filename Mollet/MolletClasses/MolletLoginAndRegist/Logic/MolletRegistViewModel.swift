//
//  MolletRegistViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/21.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletRegistViewModel {
    
    //注册信息
    var email = Variable("")
    var pwd = Variable("")
    var rePwd = Variable("")
    var name = Variable("")
    var birthday = Variable("")
    var genderBoy = Variable(true)
    var country = Variable("Country")
    //身体尺寸
    var height = Variable("")
    var weight = Variable("")
    var sizeB = Variable("")
    var sizeW = Variable("")
    var sizeH = Variable("")
    
    var accountVaild:Observable<Bool>
    var birthdayVaild:Observable<Bool>
    var countryVaild:Observable<Bool>
    var bodyVaild:Observable<Bool>
    
    let genderButtons = BehaviorRelay<[UIButton]>(value:[])
    
    var isAgree = Variable(true)
    
    init() {
        
        let emailVaild = email.asObservable()
            .map{$0.count >= 6}
            .share(replay: 1)
        
        let pwdVaild = pwd.asObservable()
            .map{$0.count >= 6}
            .share(replay: 1)
        
        let repwdVaild = rePwd.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        accountVaild = Observable.combineLatest(emailVaild, pwdVaild, repwdVaild, isAgree.asObservable()){$0 && $1 && $2 && $3}
        
        let nameVaild = name.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)

        let bVaild = birthday.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        birthdayVaild = Observable.combineLatest(nameVaild, bVaild){$0 && $1}
        
        countryVaild = country.asObservable().map{$0.count > 0 && $0 != "Country"}.share(replay: 1)
        
        let heightVaild = name.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        let weightVaild = birthday.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        let sizeBVaild = name.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        let sizeWVaild = birthday.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        let sizeHVaild = birthday.asObservable()
            .map{$0.count > 0}
            .share(replay: 1)
        
        bodyVaild = Observable.combineLatest(heightVaild, weightVaild, sizeBVaild, sizeWVaild, sizeHVaild){$0 && $1 && $2 && $3 && $4}
    }
    
    func setButtonSelectViewModel() {
        
        //将两个button的按钮点击事件合并，即获取最后一次点击的按钮
        let buttonSelect = Observable.from(genderButtons.value.map{button in
            button.rx.tap.map{ button }})
            .merge()
            .filter{[weak self] (btn) -> Bool in
                self?.genderBoy.value = btn.tag == 1 ? true : false
                return true
            }.asObservable()
        
        //如果最后点击的按钮==genderButtons中的按钮，则设置selected
        for button in self.genderButtons.value {
            buttonSelect.map{ $0 == button }
                .bind(to: button.rx.isSelected)
                .disposed(by: disposebag)
        }
        
    }
    
    //重复密码是否正确
    func rePwdVaild() -> Observable<Bool> {
        return Observable.of(false)
        .map{_ in
            return (self.pwd.value == self.rePwd.value)
        }
        .asObservable()
        
    }
    
    //注册请求
    func registRequest() -> Observable<[String:Any]> {
        let url = URL.init(string: "\(BaseApi)/Mollet/User/Register")!
        let params:[String:Any] = [
            "EmailAddress": email.value,
            "Password": pwd.value
        ]
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //完善资料
    func setUserInfoRequest() -> Observable<[String:Any]> {
        let gender = genderBoy.value == true ? "Male" : "Female"
        let url = URL.init(string: "\(BaseApi)/Mollet/ModelProfile/AddOrUpdate")!
        var params:[String:Any] = [
            "FullName": name.value,
            "Birthday": birthday.value,
            "Gender": gender,
            "Nationality": country.value,
            "Height": height.value,
            "Weight": weight.value,
            "Bust": sizeB.value,
            "Waist": sizeW.value,
            "Hips": sizeH.value
        ]
//        params = [
//            "FullName": "jack zhou",
//            "Birthday": "",
//            "Gender": gender,
//            "Nationality": country.value,
//            "Height": height.value,
//            "Weight": weight.value,
//            "Bust": sizeB.value,
//            "Waist": sizeW.value,
//            "Hips": sizeH.value,
//            "ProfilePicData": ""
//        ]
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //完善除了身材以外的资料
    func setUserInfoWithoutBodyRequest() -> Observable<[String:Any]> {
        let gender = genderBoy.value == true ? "Male" : "Female"
        let url = URL.init(string: "\(BaseApi)/Mollet/ModelProfile/AddOrUpdate")!
        let params:[String:Any] = [
            "FullName": name.value,
            "Birthday": birthday.value,
            "Gender": gender,
            "Nationality": country.value,
            "Height": "0",
            "Weight": "0",
            "Bust": "0",
            "Waist": "0",
            "Hips": "0"
        ]
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
}
