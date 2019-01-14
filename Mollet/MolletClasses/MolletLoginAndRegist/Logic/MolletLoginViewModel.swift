//
//  MolletLoginViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletLoginViewModel {
    var email = Variable("")
    var passWord = Variable("")
    
    var inputVaild:Observable<Bool>
    
    init() {
        //账号
        let emailVaild = email.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
        //密码
        let pwdVaild = passWord.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
        self.inputVaild = Observable.combineLatest(emailVaild, pwdVaild){$0 && $1}
        
        //获取存储的账号密码
        let account = UserGlobalDataTool.getUserEmail()
        let pwd = UserGlobalDataTool.getUserPwd()
        self.email.value = account
        self.passWord.value = pwd
    }
    
    func login() -> Observable<[String:Any]> {
        let url = URL.init(string: "\(BaseApi)/Mollet/User/Login")!
        let params:[String:Any] = [
            "EmailAddress": email.value,
            "Password": passWord.value
        ]
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
            //.mapDictionary()
        return result
    }
    
    func getLoginMsg() {
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
                        let userInfo = resultDic["result"] as! [String:Any]
                        self.saveUserInfo(userInfo: userInfo)
                    }else {
                        print(resultDic["result"])
                    }
                }
            })
    }
    
    func saveGlobalData() {
        //账号密码
        UserGlobalDataTool.saveUserEmail(email: email.value)
        UserGlobalDataTool.saveUserPwd(pwd: passWord.value)
        
        print(UserGlobalDataTool.getUserEmail())
    }
    
    func saveUserInfo(userInfo:[String:Any]) {
        print(userInfo)
        
        let ModelProfileId = String(describing: userInfo["ModelProfileId"] ?? "")
        let EmailAddress = String(describing: userInfo["EmailAddress"] ?? "")
        let FullName = String(describing: userInfo["FullName"] ?? "")
        let Birthday = String(describing: userInfo["Birthday"] ?? "")
        let Gender = String(describing: userInfo["Gender"] ?? "")
        let Nationality = String(describing: userInfo["Nationality"] ?? "")
        let Height = String(describing: userInfo["Height"] ?? Float(0))
        let Weight = String(describing: userInfo["Weight"] ?? Float(0))
        let Bust = String(describing: userInfo["Bust"] ?? Float(0))
        let Waist = String(describing: userInfo["Waist"] ?? Float(0))
        let Hips = String(describing: userInfo["Hips"] ?? Float(0))
        let ProfilePicUrl = String(describing: userInfo["ProfilePicUrl"] ?? "")
        let PhoneNumber = String(describing: userInfo["PhoneNumber"] ?? "")
        let profileFactUrl = "\(BaseApi)\(ProfilePicUrl)"
        
        print(userInfo["PhoneNumber"] ?? "")
        
        //合同数组
        let Contracts = userInfo["Contracts"]
        
        UserDefaults.standard.set(ModelProfileId, forKey: "ModelProfileId")
        UserDefaults.standard.set(EmailAddress, forKey: "EmailAddress")
        UserDefaults.standard.set(FullName, forKey: "FullName")
        UserDefaults.standard.set(Birthday, forKey: "Birthday")
        UserDefaults.standard.set(Gender, forKey: "Gender")
        UserDefaults.standard.set(Nationality, forKey: "Nationality")
        UserDefaults.standard.set(Height, forKey: "Height")
        UserDefaults.standard.set(Weight, forKey: "Weight")
        UserDefaults.standard.set(Bust, forKey: "Bust")
        UserDefaults.standard.set(Waist, forKey: "Waist")
        UserDefaults.standard.set(Hips, forKey: "Hips")
        UserDefaults.standard.set(profileFactUrl, forKey: "ProfilePicUrl")
        UserDefaults.standard.set(PhoneNumber, forKey: "PhoneNumber")
        UserDefaults.standard.set(Contracts, forKey: "Contracts")
        UserDefaults.standard.synchronize()
        
        //用户信息获取完成发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserInfoDidFetchNotification), object: nil)
    }
}
