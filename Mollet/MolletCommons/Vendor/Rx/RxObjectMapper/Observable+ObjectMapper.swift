//
//  Observable+ObjectMapper.swift
//  WanDeBao-Merchant
//
//  Created by 吴满乐 on 2018/5/22.
//  Copyright © 2018年 Hangzhou YunBao Technology Co., Ltd. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire

extension Observable {
    
    func mapJson() -> Observable<[String:Any]> {
        return self.map { data in
            if let resultData:Data = data as? Data {
                let jsonObject = try JSONSerialization.jsonObject(with: resultData, options: .mutableContainers)
                print(jsonObject)
                return jsonObject as! [String:Any]
            }else {
                return [String:Any]()
            }
        }
        
    }
    
    //过滤掉错误结果
    func filterSuccessResult() -> Observable<(HTTPURLResponse,Any)> {
        return self.filter({ (arg0) in
            let (response, data) = arg0 as! (HTTPURLResponse,Any)
            print("检测result====== start")
            print(data)
            print("检测result====== end")
            if let resp = response as? HTTPURLResponse,let resultData = data as? [String:Any] {
                if  200 ..< 300 ~= resp.statusCode && (resultData["ret"] as! Int == 2){
                    return true
                }else {
                    // ret==4 || ret==1
                    if let errorMsg = resultData["result"] as? String {
                        MBProgressHUDSwift.dismiss()
                        MBProgressHUDSwift.showError(errorMsg)
                    }
                    print(resultData["result"] ?? "")
                    return false
                }
            }else {
                return false
            }
        })
        .catchError{  (error) -> Observable<Element> in
            return Observable.empty()
        } as! Observable<(HTTPURLResponse, Any)>
    }
    
    func mapObject<T: Mappable>(type: T.Type, key: String? = nil) -> Observable<T> {
        return self.map { response in
            
            print("&&&&&&&&&&&&&=======\(response)")
            
            guard let dict = response as? [String: Any] else {
                throw RxSwiftAlamfire.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            if let k = key {
                guard let dictionary = dict[k] as? [String: Any] else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
                return Mapper<T>().map(JSON: dictionary)!
            }
            return Mapper<T>().map(JSON: dict)!
        }
    }
    
    func mapArray<T: Mappable>(type: T.Type, key: String? = nil) -> Observable<[T]> {
        return self.map { response in
            
            print(response)
            
            if key != nil {
                
                guard let dict = response as? [String: Any] else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
                if let error = self.parseError(response: dict) {
                    throw error
                }
                
                guard let dictionary = dict[key!] as? [[String: Any]] else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
                
                //ret = 4 没有数据 空数组
//                if let ret4String = dict[key!] as? String {
//                    return Mapper<T>().mapArray(JSONArray: [])
//                }else {
//                    throw RxSwiftAlamfire.ParseJSONError
//                }
                
                return Mapper<T>().mapArray(JSONArray: dictionary)
                
            } else {
                
                if let array = response as? [Any], let dicts = array as? [[String:Any]] {
                     return Mapper<T>().mapArray(JSONArray: dicts)
                }
                
                print(response)
//                if let responseData = response as? , let array = JSON.init(responseData.data).arrayObject, let dicts = array as? [[String: Any]] {
//                    return Mapper<T>().mapArray(JSONArray: dicts)
//                }
                
                throw RxSwiftAlamfire.ParseJSONError
            }
        }
    }
    
    
    func mapDictionary(key: String? = nil) -> Observable<[String:Any]> {
        
        return self.map{ response in
            
             print("response = \(response)")
            
             guard let dict = response as? [String: Any] else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
            
            if key != nil {
                guard let dictionary = dict[key!] as? [String: Any] else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
                return dictionary
            }
            return dict
        }
    }
    
    //返回成功 但是result为null
    func mapAny(key: String? = nil) -> Observable<Any> {
        
        return self.map{ response in
            
            print("response = \(response)")
            
            guard let dict = response as? [String: Any] else {
                throw RxSwiftAlamfire.ParseJSONError
            }
            
            if key != nil {
                guard let result = dict[key!] as? Any else {
                    throw RxSwiftAlamfire.ParseJSONError
                }
                return result
            }
            return dict
        }
    }
    
    func parseServerError() -> Observable {
        return self.map { (response) in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftAlamfire.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            return self as! Element
        }
        
    }
    
    fileprivate func parseError(response: [String: Any]?) -> NSError? {
        var error: NSError?
        if let value = response {
            if let code = value["code"] as? Int, code != 200 {
                var msg = ""
                if let message = value["error"] as? String {
                    msg = message
                }
                error = NSError(domain: "Network", code: code, userInfo: [NSLocalizedDescriptionKey: msg])
            }
        }
        return error
    }
}

enum RxSwiftAlamfire: String {
    case ParseJSONError
    case OtherError
}

extension RxSwiftAlamfire: Swift.Error {}

