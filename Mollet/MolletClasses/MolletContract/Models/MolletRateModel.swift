//
//  MolletRateModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/10/13.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import ObjectMapper

class MolletRateModel: Mappable {

    var RatingKey:String?
    var TopPercentage:Int?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable 设置映射
    func mapping(map: Map) {
        RatingKey <- map["RatingKey"]
        TopPercentage <- map["TopPercentage"]
    }
}
