//
//  MolletJobListViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MolletJobListViewModel {

    var contractId = Variable("")
    //列表数据
    var jobList = BehaviorRelay<[MolletJobModel]>(value:[])
    //本合同的百分比
    var percentage = Variable(40)
    
    //停止刷新状态序列
    let endHeaderRefreshing: Driver<Bool>
    
    init(headerRefresh:Driver<Void>,contractId:String) {
        self.contractId.value = contractId
        
        //下拉结果序列
        let headerRefreshData = headerRefresh
            //startWith 首次自动请求一次
            //.startWith(())
            .flatMapLatest{ _ in MolletJobListViewModel.getJobListRequest(contractId: contractId) }
        
        //生成停止头部刷新状态序列
        self.endHeaderRefreshing = Driver.merge(
            headerRefreshData.map{_ in true}
        )
        
        //请求数据
        headerRefreshData.drive(onNext:{ models in
            self.jobList.accept(models)
        }).disposed(by: disposebag)
    }
    
    //获取列表
    class func getJobListRequest(contractId:String) -> Driver<[MolletJobModel]> {
        
        //列表请求样例
        let urlString = "\(BaseApi)/Mollet/Job/GetAllByContractId/\(contractId)"
        print(urlString)
        let url = URL(string:urlString)!
        //创建并发起请求
        return requestJSON(.post, url)
            .filterSuccessResult()
            .map{$1}
            .mapArray(type: MolletJobModel.self, key: "result")
            .asDriver(onErrorJustReturn: [MolletJobModel]())
    }
    
    //删除工作
    func deleteJobRequest(jobId:String) -> Observable<Any> {
        let urlString = "\(BaseApi)/Mollet/Job/Delete/\(jobId)"
        let url = URL(string:urlString)!
        print(urlString)
        //创建并发起请求
        return requestJSON(.post, url)
            .filterSuccessResult()
            .map{$1}
            .mapAny(key: "result")
    }
    
    func deleteListData(model:MolletJobModel) {
        var modeArray = self.jobList.value
        print(modeArray)
        for i in 0..<self.jobList.value.count {
            let cModel = self.jobList.value[i]
            if cModel.JobId! == model.JobId {
                modeArray.remove(at: i)
            }
        }
        self.jobList.accept(modeArray)
    }
    
}
