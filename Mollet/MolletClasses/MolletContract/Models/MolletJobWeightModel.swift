//
//  MolletJobWeightModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/10/13.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import ObjectMapper

class MolletJobWeightModel: Mappable {
    
    var JobType:String?
    var Percentage:String?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable 设置映射
    func mapping(map: Map) {
        JobType <- map["Type"]
        Percentage <- map["Percentage"]
    }
}
