//
//  MolletBalanceViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletBalanceViewModel {

    var titleList = ["Apartment Fee","Utilities Fee","Transportation Fee","Composite Card","Pocket Money","Ticket Fee","Guarantee","Visa Fee"]
    //选择的类型
    var type = Variable("Guarantee")
    
    //创建一个收支列表数组
    var balanceList = BehaviorRelay<[MolletBalanceModel]>(value:[])
    //feesModels
    var feesModels = BehaviorRelay<[MolletFeeModel]>(value:[])
    
    //dropview当前选择的是哪一行
    var dropviewSelectRow = Variable(0)
    
    var contractId = Variable("")
    
    init() {
    }
    
    func setInitDataWithType(type:String) {
        self.type.value = type
        if type == "Guarantee" {
            titleList = ["Apartment Fee","Utilities Fee","Transportation Fee","Composite Card","Pocket Money","Ticket Fee","Guarantee","Visa Fee"]
        }else {
            //百分比
            titleList = ["Apartment Fee","Utilities Fee","Transportation Fee","Composite Card","Pocket Money","Ticket Fee","Visa Fee"]
        }
        var titleArray = [MolletBalanceModel]()
        for str in titleList {
            let model = MolletBalanceModel()
            model.title = str
            model.dateType = "Monthly"
            if str == "Guarantee" || str == "Composite Card" {
                model.dateType = "Onetime"
            }else if str == "Pocket Money" {
                model.dateType = "Weekly"
            }
            model.tfValue = ""
            titleArray.append(model)
        }
        balanceList.accept(titleArray)
    }
    
    //添加收支
    func addBalance() {
        var listData = self.balanceList.value
        let model = MolletBalanceModel()
        model.title = "Extra Fee"
        listData.append(model)
        self.balanceList.accept(listData)
    }
    
    //删除收支
    func deleteBalanceAtRow(row:Int) {
        var listData = self.balanceList.value
        listData.remove(at: row)
        self.balanceList.accept(listData)
    }
    
    //日期选择完毕
    func dateTypeChose(type:String) {
        //替换选中的数据
        let index = self.dropviewSelectRow.value
        var balanceArray = balanceList.value
        let model = balanceArray[index]
        model.dateType = type
        balanceArray[index] = model
        self.balanceList.accept(balanceArray)
    }
    
    //根据row设置tf的值
    func setTfValueWidthTextFiled(tf:UITextField) {
        //将数组中的model赋值 并替换
        var modelArray = balanceList.value
        let index = tf.tag - 10
        let model = modelArray[index]
        model.tfValue = tf.text
        print(model.tfValue)
        modelArray[index] = model
        balanceList.accept(modelArray)
    }
    
    //输入设置。如果没填。默认为0
    func inputValueReset() -> Observable<Bool>  {
        let modelArray = self.balanceList.value
        for model in modelArray {
//            print(model.tfValue ?? "")
            if model.tfValue?.count == 0 {
                //如果没值。设置为0
                model.tfValue = "0"
            }
        }
        self.balanceList.accept(modelArray)
        return Observable.just(true)
    }
    
    //是否显示删除按钮
    func isShowDeleteButton(row:Int) -> Bool {
        if self.type.value == "Guarantee" && row > 7 {
            return true
        }else if self.type.value == "Percentage" && row > 6 {
            return true
        }
        return false
    }
    
    func unitAtIndex(row: Int, originUnit: String) -> String {
        let cType = self.type.value
        if cType == "Guarantee" && row == 6 {
            return "$"
        }
        return originUnit
    }
    
    //新增合同请求 ----- 保证金在此页面获取。所以此接口必须放在此处
    func addContractRequest(VM:MolletContractDetailViewModel) -> Observable<[String:Any]> {
        //保证金和结算货币类型
        var guarantee = balanceList.value[6].tfValue ?? ""
        let Currency = MolletTools.getCurrencyFromCountry(country: VM.country.value)
        let city = VM.country.value == "China" ? VM.city.value : ""
        let type = VM.contractType.value
        if type == "Percentage" {
            guarantee = "0"
        }
        //请求
        let url = URL.init(string: "\(BaseApi)/Mollet/Contract/Create")!
        let params:[String:Any] = [
            "StartDate": VM.startDate.value,
            "EndDate": VM.endDate.value,
            "Country": VM.country.value,
            "City": city,
            "Currency": Currency, //结算货币类型
            "Guarantee": guarantee, //保证金
            "Percentage": VM.percentValue.value,
            "Type": type,
            "Tax":VM.taxPercentage.value
        ]
        
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //新增收支信息 遍历请求
    func addBalanceInfo() -> Observable<[[String : Any]]> {
        let modelArray = self.balanceList.value
        var requestObserArray = [Observable<[String:Any]>]()
        //如果没有选择保证金 这里还需要请求一次保证金 以便于后面更改时能查询到这个支出id
        var existGuarantee = false
        for model in modelArray {
            if model.title ?? "" == "Guarantee" {
                existGuarantee = true
            }
            let obser = self.addBalanceRequest(model: model)
            requestObserArray.append(obser)
        }
        //不存在保证金  将保证金添加进去 以便于后面更改时能查询到这个支出id
        if existGuarantee == false {
            let bModel = MolletBalanceModel()
            bModel.title = "Guarantee"
            bModel.tfValue = "0"
            bModel.dateType = "Onetime"
            let obser = self.addBalanceRequest(model: bModel)
            requestObserArray.append(obser)
        }
        //将所有请求打包。所有请求完成后才执行
        return Observable.zip(requestObserArray)
        .observeOn(MainScheduler.instance)
    }
    
    //收支增加请求
    func addBalanceRequest(model:MolletBalanceModel) -> Observable<[String:Any]> {
        let url = URL.init(string: "\(BaseApi)/Mollet/Fees/Create")!
        let params:[String:Any] = [
            "Name": model.title ?? "",
            "Amount": model.tfValue ?? "",
            "Frequency": model.dateType ?? "",
            "ContractId": contractId.value
        ]
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //如果是编辑 获取收支列表
    func fetchFeesList() {
        let contratctid = self.contractId.value
        let url = URL.init(string: "\(BaseApi)/Mollet/Fees/GetAllByContractId/\(contratctid)")!
        _ = requestJSON(.post, url)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
            .mapArray(type: MolletFeeModel.self, key: "result")
            .subscribe(onNext:{ array in
                self.feesModels.accept(array)
                self.setDefaultValueFromFeesData(array: array)
            })
    }
    
    //根据获取的列表设置默认数据
    func setDefaultValueFromFeesData(array: [MolletFeeModel]) {
        let listModelArray = self.balanceList.value
        var resultArray = [MolletBalanceModel]()
        for bModel in listModelArray {
            for feeModel in array {
                if feeModel.Name == bModel.title {
                    bModel.bId = feeModel.FeesId
                    bModel.tfValue = feeModel.Amount!.noPointString()
                    bModel.dateType = feeModel.Frequency
                    if feeModel.Amount! == "0.0" || feeModel.Amount! == "0" {
                        bModel.tfValue = ""
                    }
                }
            }
            resultArray.append(bModel)
        }
        self.balanceList.accept(resultArray)
    }
    
    
    //修改合同
    //保证金在此页面获取。所以此接口必须放在此处
    func updateContractRequest(VM:MolletContractDetailViewModel) -> Observable<[String:Any]> {
        //保证金和结算货币类型
        var guarantee = balanceList.value[6].tfValue ?? ""
        let Currency = MolletTools.getCurrencyFromCountry(country: VM.country.value)
        let city = VM.country.value == "China" ? VM.city.value : ""
        let contractId = self.contractId.value
        let type = VM.contractType.value
        if type == "Percentage" {
            guarantee = "0"
        }
        //请求
        let url = URL.init(string: "\(BaseApi)/Mollet/Contract/Edit/\(contractId)")!
        let params:[String:Any] = [
            "StartDate": VM.startDate.value,
            "EndDate": VM.endDate.value,
            "Country": VM.country.value,
            "City": city,
            "Currency": Currency, //结算货币类型
            "Guarantee": guarantee, //保证金
            "Percentage": VM.percentValue.value,
            "Type": type,
            "ContractId": self.contractId.value,
            "Tax":VM.taxPercentage.value
        ]
        
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    //查询该合同收支id -> 遍历执行更新接口 -> 返回最终打包的结果
    func updateBalanceInfo() -> Observable<[[String : Any]]> {
        let models = self.feesModels.value
        return self.repeatUpdateBalanceRequests(array: models)
    }
    
    //根据收支名匹配收支内容 调用收支接口
    func repeatUpdateBalanceRequests(array: [MolletFeeModel]) -> Observable<[[String : Any]]> {
        //所有请求的观察序列
        print(array)
        var requestObserArray = [Observable<[String:Any]>]()
        let balanceArray = self.balanceList.value
        for balanceModel in balanceArray {
            for feeModel in array {
                if feeModel.Name == balanceModel.title {
                    balanceModel.bId = feeModel.FeesId
                }
            }
            //遍历请求 如果存在id则更新 不然需要添加
            if balanceModel.bId ?? 0 != 0 {
                let obser = self.updateBalanceRequest(model: balanceModel)
                requestObserArray.append(obser)
            }
        }
        //将所有请求打包。所有请求完成后才执行
        return Observable.zip(requestObserArray)
            .observeOn(MainScheduler.instance)
    }
    
    
    //修改收支请求
    func updateBalanceRequest(model:MolletBalanceModel) -> Observable<[String:Any]> {
        let feesId = model.bId ?? 0
        print(feesId)
        let url = URL.init(string: "\(BaseApi)/Mollet/Fees/Edit/\(feesId)")!
        print(url)
        let params:[String:Any] = [
            "Name": model.title ?? "",
            "Amount": model.tfValue ?? "",
            "Frequency": model.dateType ?? "",
            "FeesId": feesId
        ]
        print(params)
        let result = requestJSON(.post, url, parameters: params, encoding: URLEncoding.default, headers: nil)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
        return result
    }
    
    
}

extension String {
    
    //去掉字符串的 .0
    func noPointString() -> String {
        let nsStr = self as NSString
        let resultStr = String(format: "%g", nsStr.floatValue)
        return resultStr
    }
}
