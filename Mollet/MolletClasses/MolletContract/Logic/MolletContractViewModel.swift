//
//  MolletJobViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import MJRefresh

class MolletContractViewModel {
    
    //合同列表
    var contractList = BehaviorRelay<[MolletContractModel]>(value:[])
    //停止刷新状态序列
    let endHeaderRefreshing: Driver<Bool>
    
    init(headerRefresh:Driver<Void>) {
        //下拉结果序列
        let headerRefreshData = headerRefresh
            //startWith 首次自动请求一次
            .startWith(())
            .flatMapLatest{ _ in MolletContractViewModel.getContractList() }
        
        //生成停止头部刷新状态序列
        self.endHeaderRefreshing = Driver.merge(
            headerRefreshData.map{_ in true}
        )
        
        //请求数据
        headerRefreshData.drive(onNext:{ models in
            print(models)
            self.contractList.accept(models)
        }).disposed(by: disposebag)
        
    }
    
    //获取列表
    class func getContractList() -> Driver<[MolletContractModel]> {
        //列表请求样例
        let urlString = "\(BaseApi)/Mollet/Contract/GetAll"
        let url = URL(string:urlString)!
        let params = ["DetailedAll":true]
        //创建并发起请求
        return requestJSON(.post, url, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{$1}
            .mapArray(type: MolletContractModel.self, key: "result")
            .asDriver(onErrorJustReturn: [MolletContractModel]())
    }
    
    //删除合同
    func deleteContract(contractId:String) -> Observable<Any> {
        let urlString = "\(BaseApi)/Mollet/Contract/Delete/\(contractId)"
        let url = URL(string:urlString)!
        print(urlString)
        //创建并发起请求
        return requestJSON(.post, url)
            .filterSuccessResult()
            .map{$1}
            .mapAny(key: "result")
    }
    
    func deleteListData(model:MolletContractModel) {
        var modeArray = self.contractList.value
        for i in 0..<self.contractList.value.count {
            let cModel = self.contractList.value[i]
            if cModel.ContractId! == model.ContractId {
                modeArray.remove(at: i)
            }
        }
        self.contractList.accept(modeArray)
    }
    
    //检测登录
    func checkLogin(gotoLogin:() -> ()) {
        
        //检测登录  跳转登录页
        let email = UserGlobalDataTool.getUserEmail()
        let pwd = UserGlobalDataTool.getUserPwd()
        if email.count > 0 && pwd.count > 0 {
            //账号密码都存在 自动登录
            self.login(email:email, pwd:pwd)
            
        }else {
            //跳转页面
            gotoLogin()
//            let loginVC = MolletLoginViewController()
//            let navigationVC = MolletNavigationController.init(rootViewController: loginVC)
//            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    //静默登录
    func login(email:String, pwd:String) {
        
        let url = URL.init(string: "\(BaseApi)/Mollet/User/Login")!
        let params:[String:Any] = [
            "EmailAddress": email,
            "Password": pwd
        ]
        _ = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
            .subscribe(onNext:{ _ in
                //登录成功
                self.getLoginMsg()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshContractListNotification), object: nil)
            })
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
    }
    
}


