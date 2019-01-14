//
//  MolletJobModel.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import ObjectMapper

class MolletJobModel: Mappable {
    
    var Name:String?
    var JobId:Int?
    var JType:String?
    var Date:String?
    var Booker:String?
    var Hours:String?
    var HourlyPay:String?
    var ContractId:Int?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable 设置映射
    func mapping(map: Map) {
        Name <- map["Name"]
        JobId <- map["JobId"]
        JType <- map["Type"]
        Date <- map["Date"]
        Booker <- map["Booker"]
        Hours <- map["Hours"]
        HourlyPay <- map["HourlyPay"]
        ContractId <- map["ContractId"]
    }
}
