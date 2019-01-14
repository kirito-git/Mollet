//
//  MolletFeeModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/10/10.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import ObjectMapper

class MolletFeeModel: Mappable {

    var FeesId:Int?
    var Name:String?
    var Amount:String?
    var Frequency:String?
    var ContractId:Int?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable 设置映射
    func mapping(map: Map) {
        FeesId <- map["FeesId"]
        Name <- map["Name"]
        Amount <- map["Amount"]
        Frequency <- map["Frequency"]
        ContractId <- map["ContractId"]
    }
}
