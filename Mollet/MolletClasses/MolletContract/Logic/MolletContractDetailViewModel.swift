//
//  MolletContractDetailViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class MolletContractDetailViewModel {

    //将要选择的按钮放入数组中
    var typeButtons = BehaviorRelay<[UIButton]>(value:[])
    var percentButtons = BehaviorRelay<[UIButton]>(value:[])
//    //是否选择了百分比 ，只有type选择了百分比 下面的百分比按钮才可点击
//    var percentageIsSelect = Variable(false)
    //国家选择了才能选择城市
    var isSelectedChina:Observable<Bool>
    //开始时间
    var startDate = Variable("Start date")
    //结束时间
    var endDate = Variable("End date")
    //国家
    var country = Variable("Country")
    //城市
    var city = Variable("City")
    //合同类型
    var contractType = Variable("Guarantee")
    //百分比
    var percentValue = Variable("40")
    //税收
    var taxPercentage = Variable("0")
    
    var inputVaild:Observable<Bool>
    
    var cityVaild:Observable<Bool>
    
    init() {
        //只有选择了China,India,Japan,USA 才可选择城市
        self.isSelectedChina = country.asObservable().map{$0 == "China" || $0 == "India" || $0 == "Japan" || $0 == "United States"}
        
        let startDataVaild = startDate.asObservable()
            .map{ $0.count > 0 && $0 != "Start date" }
            .share(replay: 1)
        
        let endVaild = endDate.asObservable()
            .map{ $0.count > 0 && $0 != "End date" }
            .share(replay: 1)

        let countryVaild = country.asObservable()
            .map{ $0.count > 0 && $0 != "Country" }
            .share(replay: 1)
        
        let percentageVaild = percentValue.asObservable()
            .map{ $0.count > 0 }
            .share(replay: 1)
        
        let cityvaild = city.asObservable()
            .map{ $0.count > 0 && $0 != "City" }
        
        inputVaild = Observable.combineLatest(startDataVaild,endVaild,countryVaild,percentageVaild){$0 && $1 && $2 && $3}
        
        cityVaild = Observable.combineLatest(isSelectedChina, cityvaild){ ($0 && $1) || !$0 }
    }
    
    //类型单选设置
    func typeSingleSelect() {
        //创建一个观察序列 发送最后一次点击的按钮
        let typeSelectButton = Observable.from(self.typeButtons.value.map {
            button in
            button.rx.tap.map{ button } }
            ).merge()
            .filter{ [weak self] (btn) -> Bool in
                if btn.tag == 11 {
                    self?.contractType.value = "Guarantee"
                }else if btn.tag == 12 {
                    self?.contractType.value = "Percentage"
                }
                return true
            }.asObservable()
        
//        //是否选择了百分比
//        _ = typeSelectButton.subscribe(onNext:{ [weak self] (button) in
//            if button.tag == 12 {
//                self?.percentageIsSelect.value = true
//            }else {
//                self?.percentageIsSelect.value = false
//                //点击了保证金类型 则将百分比按钮清除
//                _ = self?.percentButtons.value.map{ button in
//                    button.isSelected = false
//                }
//            }
//        })
        
        for button in self.typeButtons.value {
            typeSelectButton.map{ $0 == button }
                .bind(to: button.rx.isSelected)
                .disposed(by: disposebag)
        }
    }
    
    //百分比单选设置
    func percentSingleSelect() {
        //创建一个观察序列 发送最后一次点击的按钮
        let pSelectButton = Observable.from(self.percentButtons.value.map {
            button in
            button.rx.tap.map{ button }
        })
            .merge()
            .filter { [weak self] (btn) -> Bool in
                if btn.tag == 13 {
                    self?.percentValue.value = "40"
                }else if btn.tag == 14 {
                    self?.percentValue.value = "50"
                }else {
                    self?.percentValue.value = "60"
                }
                return true
            }
            .asObservable()
        
        for button in self.percentButtons.value {
            pSelectButton.map{ $0 == button }
                .bind(to: button.rx.isSelected)
                .disposed(by: disposebag)
        }
    }
    
    //检测输入是否有效
    func inputAndCityVaild() -> Observable<Bool> {
        return Observable.combineLatest(cityVaild, inputVaild){ $0 && $1 }
    }
    
    //拼接百分号
    func appendPercentageSign(text:String) -> String {
        let originStr = text
        //先删除所有的%
        var resultStr = originStr.replacingOccurrences(of: "%", with: "")
        if resultStr.count > 0 {
            if let num = Float(resultStr) {
                if num > Float(100) {
                    resultStr = "0"
                }
            }else {
                resultStr = "0"
            }
        }else {
            resultStr = "0"
        }
        self.taxPercentage.value = resultStr
        //再拼接一个
        return "\(resultStr)%"
    }
    
}
