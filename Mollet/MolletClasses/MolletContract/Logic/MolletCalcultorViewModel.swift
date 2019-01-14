//
//  MolletCalcultorViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/26.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper

class MolletCalcultorViewModel {
    
    var contractId = Variable("")
    var cModel:MolletContractModel?
    var jobWeightArray = BehaviorRelay<[MolletJobWeightModel]>(value:[])
    //income
    var income = Variable("0")
    //wallet
    var wallet = Variable("0")
    //expense
    var expense = Variable("0")
    //countDown
    var countDown = Variable("99")
    
    init() {
        //初始化各type工作占比为0
        let typeArray = ["Catalog","Event","Show","TVC","Video AD","Others"]
        let jobWeights = typeArray.map({ string -> [String:Any] in
            return ["Type":string, "Percentage": 0]
        })
        let modelArray = Mapper<MolletJobWeightModel>().mapArray(JSONArray: jobWeights)
        self.jobWeightArray.accept(modelArray)
    }
    
    //合同收支占比
    func contractDetailRequest(){
        let contratctid = self.contractId.value
        print(contratctid)
        let url = URL.init(string: "\(BaseApi)/mollet/contract/extradetails/\(contratctid)")!
        _ = requestJSON(.post, url)
            .filterSuccessResult()
            .map{ $1 as! [String:Any]}
            .mapDictionary(key: "result")
            .subscribe(onNext:{ response in
                self.resetCalcultorData(result: response)
                self.resetJobWeightModel(result: response)
                MBProgressHUDSwift.dismiss()
            })
    }
    
    func setContractModel(model:MolletContractModel) {
        self.cModel = model
        self.contractId.value = (self.cModel?.ContractId ?? 0).description
        
        //倒计时
        let daysNum = MolletTools.calculatorCountDownNum(endDateStr: model.EndDate ?? "", isStartDate: false)
        self.countDown.value = String(describing: daysNum)
    }
    
    //处理返回数据
    func resetCalcultorData(result: [String:Any]) {
        //实际收入wallet
        var jobIncome = result["Income"] as? String ?? "0"
        if Int(jobIncome) ?? 0 < 0 {
            jobIncome = "0"
        }
        let expense = result["Expense"] as? String ?? "0"
        let walletStr = result["Wallet"] as? String ?? "0"
        //let type = self.cModel?.CType ?? "Guarantee"
        //let guarantee = String(describing: self.cModel?.Guarantee ?? 0)
        //本地计算 此处直接从服务器获取最终数据 不需计算
        //let wallet:Float = MolletTools.getWallet(jobIncome: jobIncome, expense: expense, type: type, guarantee: guarantee)

        self.income.value = jobIncome
        self.expense.value = expense
        self.wallet.value = walletStr
    }
    
    //计算不同type的工作占比
    func resetJobWeightModel(result: [String:Any]) {
        guard let JobRates = result["JobRates"] as? [[String:Any]] else {
            print("没有工作！！！！！！")
            return
        }
        let jmodels = Mapper<MolletJobWeightModel>().mapArray(JSONArray: JobRates)
        let zeroModels = self.jobWeightArray.value
        var resultModels = [MolletJobWeightModel]()
        for zmodel in zeroModels {
            //zeroModels 为外层 6个数据
            for jmodel in jmodels {
                if jmodel.JobType! == zmodel.JobType! {
                    zmodel.Percentage = jmodel.Percentage
                }
            }
            resultModels.append(zmodel)
        }
        
        self.jobWeightArray.accept(resultModels)
    }

}


