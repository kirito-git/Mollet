//
//  MolletForgetPasswordViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/27.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletForgetPasswordViewModel {
    
    var email = Variable("")
    var code = Variable("")
    var pwd = Variable("")
    
    var sendCodeVaild:Observable<Bool>
    var inputVaild:Observable<Bool>
    
    init() {
        
        let emailVaild = email.asObservable().map{$0.count > 0}
        let codeVaild = code.asObservable().map{$0.count > 0}
        let pwdVaild = pwd.asObservable().map{$0.count > 0}
        
        sendCodeVaild = emailVaild
        inputVaild = Observable.combineLatest(emailVaild, codeVaild, pwdVaild){$0 && $1 && $2}
    }
    
    //发送验证码
    func sendCodeRequest() -> Observable<[String:Any]> {
        let url = URL.init(string: "\(BaseApi)/mollet/user/forget")!
        let params = ["emailaddress":self.email.value]
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //设置密码
    func resetPwdRequest() -> Observable<[String:Any]> {
        let url = URL.init(string: "\(BaseApi)/mollet/user/forget")!
        let params = ["emailaddress":self.email.value]
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
}
