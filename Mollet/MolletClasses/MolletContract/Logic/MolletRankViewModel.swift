//
//  MolletRankViewModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MolletRankViewModel {
    
    var headerImage = Variable("")
    var name = Variable("")
    var countryRate = Variable("0")
    var countryTop = Variable("0")
    var cityRate = Variable("0")
    var cityTop = Variable("0")
    var country = Variable("")
    var city = Variable("")
    
    var isExistCity = Variable(false)
    
    init() {
        self.getUInfoFromUserDefault()
    }
    
    func setRankValue(array:[MolletRateModel]) {
        if array.count > 0 {
            
            //第一项为国家排名
            let model = array[0]
            var factValue = 100 - (model.TopPercentage ?? 0)
            factValue = min(99, factValue)
            self.countryRate.value = factValue.description
            self.countryTop.value = (100 - factValue).description
            self.country.value = model.RatingKey ?? ""
            
            if array.count == 2 {
                
                self.isExistCity.value = true
                
                //第二项为省排名
                let model2 = array[1]
                var cityFactValue = 100 - (model2.TopPercentage ?? 0)
                cityFactValue = min(99, cityFactValue)
                self.cityRate.value = cityFactValue.description
                self.cityTop.value = (100 - cityFactValue).description
                self.city.value = model2.RatingKey ?? ""
            }
        }
    }
    
    func getUInfoFromUserDefault() {
        
        headerImage.value = UserGlobalDataTool.getProfilePicUrl()
        name.value = UserGlobalDataTool.getFullName()
    }
}
