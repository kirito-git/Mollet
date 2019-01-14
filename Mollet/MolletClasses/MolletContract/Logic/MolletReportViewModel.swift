//
//  MolletReportViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletReportViewModel {
    
    //工作列表
    var jobList = BehaviorRelay<[MolletJobModel]>(value:[])
    //圆形进度数据
    var progressArray = BehaviorRelay<[String]>(value:[])
    //是否已完成
    var isComplete = Variable(false)
    //Earning
    var earningValue = Variable("")
    //EarningProgress 百分之    
    var countryRate = Variable(0)
    //排行数组
    var rateArray = BehaviorRelay<[MolletRateModel]>(value:[])
    //leftdays
    var leftdays = Variable("0")
    //合同id
    var contractId = Variable("")
    
    init() {
    }
    
    //收入排名查询
    func incomeRank() {
        let contractID = self.contractId.value
        let url = URL.init(string: "\(BaseApi)/Mollet/Query/ContractRating/\(contractID)")!
        _ = requestJSON(.post, url)
            .filterSuccessResult()
            .map{ $1 }
            .mapArray(type: MolletRateModel.self, key: "result")
            .subscribe(onNext:{ [weak self] array in
                if array.count > 0 {
                    var factValue = 100 - (array[0].TopPercentage ?? 0)
                    if factValue == 100 {
                        //如果是百分百 则设置成百分之99
                        factValue = 99
                    }
                    self?.countryRate.value = factValue
                    self?.rateArray.accept(array)
                }
                print(array)
            })
    }
    
    //获取列表
    func getJobListRequest() {
        //列表请求样例
        let urlString = "\(BaseApi)/Mollet/Job/GetAllByContractId/\(contractId.value)"
        print(urlString)
        let url = URL(string:urlString)!
        //创建并发起请求
        _ = requestJSON(.post, url)
            .map{$1}
            .mapArray(type: MolletJobModel.self, key: "result")
            .subscribe(onNext: { (array: [MolletJobModel]) in
                self.jobList.accept(array)
                MBProgressHUDSwift.dismiss()
            }).disposed(by: disposebag)
    }
    
    func setReportDataFromPassingValue(viewmodel:MolletCalcultorViewModel) {
        
        let contractModel = viewmodel.cModel
        //设置contractid
        self.contractId.value = String(describing: contractModel?.ContractId ?? 0)
        //设置圆形进度数据 Int数组
        self.setCircleProgressData(viewmodel: viewmodel)
        //是否完成
        let endDate = contractModel?.EndDate ?? ""
        let isOutOfDate = MolletTools.dateIsOutOfNow(endDateStr: endDate)
        self.isComplete.value = isOutOfDate ? true : false
        //设置left days
        self.leftdays.value = self.reportLeftDays(cModel: contractModel!)
        //排行查询
        self.incomeRank()
    }
    
    //圆形进度数据
    func setCircleProgressData(viewmodel:MolletCalcultorViewModel) {
        let modelArray = viewmodel.jobWeightArray.value
        var progressArray = ["0","0","0","0","0","0"]
        for i in 0..<modelArray.count {
            let value = modelArray[i].Percentage
            let floatStr = String(format: "%g", Float(value ?? "0")!)
            progressArray[i] = floatStr
        }
//        print(progressArray)
        self.progressArray.accept(progressArray)
    }
    
    //已工作的时间
    func reportLeftDays(cModel: MolletContractModel) -> String {
        
        let dataFrormatter = DateFormatter.init(withFormat: "yyyy-MM-dd", locale: "")
        
        //开始日期
        let startDateStr = cModel.StartDate!
        let startDate = dataFrormatter.date(from: startDateStr)
        //结束日期
        let endDateStr = cModel.EndDate!
        let endDate = dataFrormatter.date(from: endDateStr)
        //现在日期
        let nowDate = Date()
        
        //计算相差天数
        let components = Calendar.current.dateComponents([.day], from: nowDate, to: endDate!)
        var day = components.day
        //是否已经过期（完成）
        if day! < 0 {
            //过期了
            let components1 = Calendar.current.dateComponents([.day], from: startDate!, to: endDate!)
            day = components1.day
            
        }else {
            //正在进行 计算初始日期和现在的时间差
            let components2 = Calendar.current.dateComponents([.day], from: startDate!, to: nowDate)
            day = components2.day
        }
        
        let result = String(describing: abs(day!))
        print(result)
        return result
    }
    
}
