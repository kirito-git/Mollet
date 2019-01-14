//
//  MolletJobAddViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletJobAddViewModel {

    var name = Variable("")
    var type = Variable("Catalog")
    var date = Variable("")
    var booker = Variable("")
    var jobHours = Variable("")
    var payment = Variable("")
    var totalPay = Variable("")
    
    var contractId = Variable("")

    var dropList = BehaviorRelay<[String]>(value:["Catalog","Event","Show","TVC","Video AD","Others"])
    
    var inputVaild:Observable<Bool>
    
    init() {
        
        let nameVaild = name.asObservable().map{$0.count > 0}.share(replay: 1)
        let typeVaild = type.asObservable().map{$0.count > 0}.share(replay: 1)
        let dateVaild = date.asObservable().map{$0.count > 0}.share(replay: 1)
//        let bookerVaild = booker.asObservable().map{$0.count > 0}.share(replay: 1)
        let jobHoursVaild = jobHours.asObservable().map{$0.count > 0 && Float($0) != nil && Float($0)! > Float(0)}.share(replay: 1)
        let paymentVaild = payment.asObservable().map{$0.count > 0 && Float($0) != nil && Float($0)! > Float(0)}.share(replay: 1)
        let totalPayVaild = totalPay.asObservable().map{$0.count > 0}.share(replay: 1)
        
        inputVaild = Observable.combineLatest(nameVaild,typeVaild,dateVaild,jobHoursVaild,paymentVaild){$0 && $1 && $2 && $3 && $4}
        
    }
    
    //添加工作
    func addContractJobRequest() -> Observable<[String:Any]> {
        //请求
        let url = URL.init(string: "\(BaseApi)/Mollet/Job/Create")!
        let params:[String:Any] = [
            "Name": name.value,
            "Type": type.value,
            "Date": date.value,
            "Booker": booker.value,
            "Hours": jobHours.value,
            "HourlyPay": payment.value,
            "ContractId": self.contractId.value
        ]
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //修改工作
    func updateContractJobRequest(jobId:String) -> Observable<[String:Any]> {
        
        let url = URL.init(string: "\(BaseApi)/Mollet/Job/Edit/\(jobId)")!
        let params:[String:Any] = [
            "Name": name.value,
            "Type": type.value,
            "Date": date.value,
            "Booker": booker.value,
            "Hours": jobHours.value,
            "HourlyPay": payment.value,
            "JobId": jobId
        ]
        print(url)
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //将小数点后的数字变成 0 或 5   去掉
    func stringTransform(originStr: String) -> String {
        var resultStr = originStr
        if originStr.contains(".") {
            //分割字符串
            let strArray = originStr.components(separatedBy: ".")
            var decade = Float(strArray[0])!
            var theUnit = Float("0.\(strArray[1])")!
            if theUnit <= 0.5 && theUnit > 0 {
                theUnit = 0.5
            }else {
                theUnit = 0
                decade = decade + 1
            }
            let result = decade + theUnit
            resultStr = String(format:"%g",result)
            print(resultStr)
        }
        return resultStr
    }
}
