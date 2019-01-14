//
//  CountryTools.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/25.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import Foundation

class CountryTools {
    //将数据分类
    class func getCountryDatas() -> ([[[String:Any]]],[String]) {
        //查询数据库
        let countryArray = SqliteManager.default.selectTable()
        //创建一个字典用以获取所有国家不重复的首字母
        var firstLetterDic = [String:Any]()
        
        for countryDic in countryArray {
            //获取首字母
            let countryStr = countryDic["name"] as! String
            //获取首字母
            let firstMember = CountryTools.getFirstMember(letter: countryStr)
            //设置键值，值为""，只为记录所有键，去重
            firstLetterDic[firstMember] = ""
        }
        
        //所有国家的首字母不重复数组
        //排序
        let result = firstLetterDic.sorted(by: { (str1, str2) -> Bool in
            return str1.0 < str2.0
        }).map { (key , _ ) in
            return key
        }
        
        //创建分区的数据
        let sectionArray = result.map { (key) -> [[String : Any]] in
            //创建小数组 里面包含同首字母的字典
            var itemArray = [[String:Any]]()
            _ = countryArray.map({ (dic) in
                //获取到首字母与外层比较
                let name = dic["name"] as! String
                let firstC = CountryTools.getFirstMember(letter: name)
                if key == firstC {
                    itemArray.append(dic)
                }
            })
            return itemArray
        }
        return (sectionArray,result)
    }
    
    //获取首字母
    class func getFirstMember(letter:String) -> String {
        //获取首字母
        let index = letter.index(letter.startIndex, offsetBy: 0)
        let firstMember = letter[index]
        return String(describing: firstMember)
    }

    //获取城市列表
    class func getCityDatas(country:String) -> ([[String]],[String]) {
        
        if country == "China" {
            return CountryTools.getChinaCities()
        }
        return CountryTools.getOtherCountryCities(country: country)
    }
    
    //中国城市
    class func getChinaCities() -> ([[String]],[String]) {
        //转换市列表数据 合并为一个数组
        let path = Bundle.main.path(forResource: "pyCity", ofType: "plist")
        let cityArr = NSArray.init(contentsOfFile: path as! String) as! [[String:Any]]
        var city_bigArray = [String]()
        for dic in cityArr {
            let cities = dic["cities"] as! [String]
            city_bigArray += cities
        }
        //创建一个字典用以获取所有城市不重复的首字母
        var firstLetterDic = [String:Any]()
        
        for cityStr in city_bigArray {
            //获取首字母
            let firstMember = CountryTools.getFirstMember(letter: cityStr)
            //设置键值，值为""，只为记录所有键，去重
            firstLetterDic[firstMember] = ""
        }
        
        //所有国家的首字母不重复数组
        //排序
        let result = firstLetterDic.sorted(by: { (str1, str2) -> Bool in
            return str1.0 < str2.0
        }).map { (key , _ ) in
            return key
        }
        
        //创建分区的数据
        let sectionArray = result.map { (key) -> [String] in
            //创建小数组 里面包含同首字母的字典
            var itemArray = [String]()
            _ = city_bigArray.map({ (Str) in
                //获取到首字母与外层比较
                let firstC = CountryTools.getFirstMember(letter: Str)
                if key == firstC {
                    itemArray.append(Str)
                }
            })
            return itemArray
        }
        return (sectionArray,result)
    }
    
    //获取其他国家的城市列表
    class func getOtherCountryCities(country: String) -> ([[String]],[String]) {
        //转换市列表数据 合并为一个数组
        
        var path = ""
        if country == "United States" {
            path = Bundle.main.path(forResource: "USA", ofType: "json")!
        }else if country == "India" {
            path = Bundle.main.path(forResource: "India", ofType: "json")!
        }else if country == "Japan" {
            path = Bundle.main.path(forResource: "Japan", ofType: "json")!
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json:Any = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers)
            let cityList = json as! [[String]]
            
            //所有城市的首字母不重复数组
            var result = ["A","B","C","D","E", "F", "G", "H", "I","J", "K","L", "M", "N", "O", "P","Q","R","S", "T","U","V", "W","X","Y","Z",]
            if country == "United States" {
                result = ["A", "C", "D", "F", "G", "H", "I", "K", "L", "M", "N", "O", "P", "R", "S", "T", "U", "V", "W"]
            }else if country == "India" {
                result = ["A", "B", "C", "D", "G", "H", "J", "K", "L", "M", "N", "O", "P", "R", "S", "T", "U", "W"]
            }else if country == "Japan" {
                result = ["A", "C", "E", "F", "G", "H", "I", "K", "M", "N", "O", "S", "T", "W", "Y"]
            }
            print(cityList)
            
            return (cityList, result)
        }catch let error as Error! {
            print("读取本地数据出现错误！",error)
        }
        return ([[String]](),[String]())
    }
}

