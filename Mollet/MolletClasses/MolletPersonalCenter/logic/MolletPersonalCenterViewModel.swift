//
//  MolletPersonalCenterViewModel.swift
//  Mollet
//
//  Created by wml on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

class MolletPersonalCenterViewModel {
    
    var profileUrl = Variable("")
    var name = Variable("")
    var gender = Variable("")
    var country = Variable("")
    var birthday = Variable("")
    var weight = Variable("0")
    var height = Variable("0")
    var sizeB = Variable("0")
    var sizeW = Variable("0")
    var sizeH = Variable("0")
    var phone = Variable("")
    
    var profileImage:UIImage?
    
    var nameVaild:Observable<Bool>
    var birthdayVaild:Observable<Bool>
    var weightVaild:Observable<Bool>
    var heightVaild:Observable<Bool>
    var sizeBVaild:Observable<Bool>
    var sizeWVaild:Observable<Bool>
    var sizeHVaild:Observable<Bool>
    
    init() {
        
         nameVaild = name.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         birthdayVaild = birthday.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         weightVaild = weight.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         heightVaild = height.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         sizeBVaild = sizeB.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         sizeWVaild = sizeW.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
         sizeHVaild = sizeH.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
        self.getUserInfoFromUserDefault()
    }
    
    func getUserInfoFromUserDefault() {
        
        profileUrl.value = UserGlobalDataTool.getProfilePicUrl()
        name.value = UserGlobalDataTool.getFullName()
        gender.value = UserGlobalDataTool.getGender()
        country.value = UserGlobalDataTool.getNationality()
        birthday.value = UserGlobalDataTool.getBirthday()
        weight.value = UserGlobalDataTool.getWeight()
        height.value = UserGlobalDataTool.getHeight()
        sizeB.value = UserGlobalDataTool.getBust()
        sizeW.value = UserGlobalDataTool.getWaist()
        sizeH.value = UserGlobalDataTool.getHips()
        phone.value = UserGlobalDataTool.getPhone()
    }
    
    //更新用户资料
    func updateUserInfo(replaceDic:[String:String]) -> Observable<[String:Any]> {
        
        //image -> base64字符串
        //var imageBase64Str = MolletTools.base64StringFromImage(image: self.profileImage!)
        let url = URL.init(string: "\(BaseApi)/Mollet/ModelProfile/AddOrUpdate")!
        var params = [
            "FullName": name.value,
            "Birthday": birthday.value,
            "Gender": gender.value,
            "Nationality": country.value,
            "Height": height.value,
            "Weight": weight.value,
            "Bust": sizeB.value,
            "Waist": sizeW.value,
            "Hips": sizeH.value
        ]
        //只设置当前值
        for key in replaceDic.keys {
            let value = replaceDic[key]
            params[key] = value
        }
        //print(params)
        return requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any] }
    }
    
    //保存到UserDefault里
    func saveUserInfo(replaceDic:[String:String]) {
        for key in replaceDic.keys {
            let value = replaceDic[key]
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    //获取用户头像  然后保存
    func saveUserAvatar() {
        let url = URL.init(string: "\(BaseApi)/Mollet/ModelProfile/Details")!
        _ = requestJSON(.post, url)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
            .mapDictionary()
            .subscribe(onNext:{ response in
                print(response)
                //保存用户信息
                if let resultDic = response as? [String:Any] {
                    if resultDic["ret"] as! Int == 2 {
                        //保存用户头像
                        let userInfo = resultDic["result"] as! [String:Any]
                        let ProfilePicUrl = String(describing: userInfo["ProfilePicUrl"] ?? "")
                        let profileFactUrl = "\(BaseApi)\(ProfilePicUrl)"
                        
                        UserDefaults.standard.set(profileFactUrl, forKey: "ProfilePicUrl")
                        UserDefaults.standard.synchronize()
                    }
                }
            })
    }
    
    func logout() {
        UserGlobalDataTool.saveUserEmail(email: "")
        UserGlobalDataTool.saveUserPwd(pwd: "")
        UserDefaults.standard.set("", forKey: "ModelProfileId")
        UserDefaults.standard.set("", forKey: "EmailAddress")
        UserDefaults.standard.set("", forKey: "FullName")
        UserDefaults.standard.set("", forKey: "Birthday")
        UserDefaults.standard.set("", forKey: "Gender")
        UserDefaults.standard.set("", forKey: "Nationality")
        UserDefaults.standard.set("", forKey: "Height")
        UserDefaults.standard.set("", forKey: "Weight")
        UserDefaults.standard.set("", forKey: "Bust")
        UserDefaults.standard.set("", forKey: "Waist")
        UserDefaults.standard.set("", forKey: "Hips")
        UserDefaults.standard.set("", forKey: "ProfilePicUrl")
        UserDefaults.standard.set("", forKey: "Contracts")
        UserDefaults.standard.set("", forKey: "PhoneNumber")
        UserDefaults.standard.synchronize()
    }

}
