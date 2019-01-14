//
//  SqliteManager.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/25.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//
import Foundation
import SQLite

class SqliteManager {
    
    var db:Connection!
    static let `default` = SqliteManager()
    
    init() {
        let path = Bundle.main.path(forResource: "global_country", ofType: "sqlite3")
        //连接本地数据库
        do {
            db = try Connection(String(describing: path!), readonly: true)
        }catch {
            print("数据库连接失败！")
        }
    }
    
    //查询数据库 SELECT * FROM TABLE
    func selectTable() -> [[String:Any]] {
        let countrys = Table("ds_country")
        //查询数据库
        var resultArray = [[String:Any]]()
        for country in (try! db.prepare(countrys)) {
            let cid = country[Expression<Int64>("id")]
            let name = country[Expression<String>("name")]
            let dic:[String:Any] = [
                "id": cid,
                "name": name
            ]
            resultArray.append(dic)
        }
        return resultArray
    }
    
    //查询数据库 SELECT * FROM TABLE WHERE id = ""
    func selectTable(countryId:Int64) -> [String:Any] {
        let countrys = Table("ds_country")
        var resultDic = [String:Any]()
        print(countryId)
        //查询结果集
        let result = countrys.filter(Expression<Int64>("id") == countryId)
        var resultArray = [Row]()
        for item in try! db.prepare(result) {
            resultArray.append(item)
        }
        if resultArray.count == 0 {
            print("未查询到结果！")
            return [String:Any]()
        }
        let resultRow = resultArray.first
        //获取所有字段 放入字典
        let cid = resultRow![Expression<Int64>("id")]
        let name = resultRow![Expression<String>("name")]
        let zh_name = resultRow![Expression<String>("zh_name")]
        let code = resultRow![Expression<String>("code")]
        let code2 = resultRow![Expression<String>("code2")]
        resultDic =  [
            "id": cid,
            "name": name,
            "zh_name": zh_name,
            "code": code,
            "code2": code2
        ]
        return resultDic
    }
    
}
