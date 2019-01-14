//
//  MolletJobModels.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import ObjectMapper

class MolletContractModel: Mappable {

    var ContractId:Int?
    var Name:String?
    var StartDate:String?
    var EndDate:String?
    var Country:String?
    var City:String?
    var CType:String?
    var Percentage:Int?
    var Guarantee:Int?
    var status:String?
    var Tax:String?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable 设置映射
    func mapping(map: Map) {
        ContractId <- map["ContractId"]
        Name = "Contract"
        StartDate <- map["StartDate"]
        EndDate <- map["EndDate"]
        Country <- map["Country"]
        City <- map["City"]
        CType <- map["Type"]
        Percentage <- map["Percentage"]
        Guarantee <- map["Guarantee"]
        Tax <- map["Tax"]
        let isOutOfDate = MolletTools.dateIsOutOfNow(endDateStr: EndDate ?? "")
        status = isOutOfDate ? "Completed" : "Processing"
    }

}
