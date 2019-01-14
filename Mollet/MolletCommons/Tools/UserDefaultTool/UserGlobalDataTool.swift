//
//  UserGlobalDataTool.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/28.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class UserGlobalDataTool {
    
    //MARK - 用户信息
    //保存Token
    class func saveToken(token:String) {
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.synchronize()
    }
    //获取token
    class func getToken() -> String {
        let token = UserDefaults.standard.value(forKey: "token") as? String ?? ""
        return token
    }
    
    //保存UserId
    class func saveSpecialUserId(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.synchronize()
    }
    //取出UserId
    class func getSpecialUserId() -> String {
        let userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        return userId
    }
   
    //保存头像
    class func saveAvatar(imageUrl: String) {
        UserDefaults.standard.set(imageUrl, forKey: "userAvatar")
        UserDefaults.standard.synchronize()
    }
    //取出头像
    class func getAvatar() -> String {
        let imageUrl = UserDefaults.standard.value(forKey: "userAvatar") as? String ?? ""
        return imageUrl
    }
    
    //保存账号
    class func saveUserEmail(email:String) {
        print(email)
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.synchronize()
    }
    //取出账号
    class func getUserEmail() -> String {
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        print(email)
        return email
    }
    
    //保存密码
    class func saveUserPwd(pwd:String) {
        UserDefaults.standard.set(pwd, forKey: "password")
        UserDefaults.standard.synchronize()
    }
    //取出密码
    class func getUserPwd() -> String {
        let pwd = UserDefaults.standard.value(forKey: "password") as? String ?? ""
        return pwd
    }
    
    //获取用户信息 *************************************
    
    class func getModelProfileId() -> String {
        let value = UserDefaults.standard.value(forKey: "ModelProfileId") as? String ?? ""
        return value
    }
    class func getEmailAddress() -> String {
        let value = UserDefaults.standard.value(forKey: "EmailAddress") as? String ?? ""
        return value
    }
    class func getFullName() -> String {
        let value = UserDefaults.standard.value(forKey: "FullName") as? String ?? ""
        return value
    }
    class func getBirthday() -> String {
        let value = UserDefaults.standard.value(forKey: "Birthday") as? String ?? ""
        return value
    }
    class func getGender() -> String {
        let value = UserDefaults.standard.value(forKey: "Gender") as? String ?? ""
        return value
    }
    class func getNationality() -> String {
        let value = UserDefaults.standard.value(forKey: "Nationality") as? String ?? ""
        return value
    }
    class func getHeight() -> String {
        if let value = UserDefaults.standard.value(forKey: "Height") as? String  {
            return value
        }
        return ""
    }
    class func getWeight() -> String {
        if let value = UserDefaults.standard.value(forKey: "Weight") as? String  {
            return value
        }
        return ""
    }
    class func getBust() -> String {
        if let value = UserDefaults.standard.value(forKey: "Bust") as? String  {
            return value
        }
        return ""
    }
    class func getWaist() -> String {
        if let value = UserDefaults.standard.value(forKey: "Waist") as? String  {
            return value
        }
        return ""
    }
    class func getHips() -> String {
        if let value = UserDefaults.standard.value(forKey: "Hips") as? String  {
            return value
        }
        return ""
    }
    class func getProfilePicUrl() -> String {
        let value = UserDefaults.standard.value(forKey: "ProfilePicUrl") as? String ?? ""
        return value
    }
    class func getContracts() -> [Int] {
        let value = UserDefaults.standard.value(forKey: "Contracts") as? [Int] ?? [Int]()
        return value
    }
    class func getPhone() -> String {
        let value = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        return value
    }
     
    
    //是否第一次下载App，用以显示引导页
    //保存 是否显示引导页
    class func saveIsLoadGuidePage(isLoadGuidePage: Bool){
        UserDefaults.standard.set(isLoadGuidePage, forKey: "isLoadGuidePage")
        UserDefaults.standard.synchronize()
    }
    //获取是否需要引导页
    class func getIsLoadGuidePage() -> Bool {
        let isLoadGuidePage = UserDefaults.standard.value(forKey: "isLoadGuidePage") as? Bool ?? false
        return isLoadGuidePage;
    }
    
}
