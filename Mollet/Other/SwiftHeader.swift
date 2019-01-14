//
//  SwiftHeader.swift
//  Mollet
//
//  Created by wml on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import Alamofire
import ObjectMapper
import SDWebImage

func ColorFromRGBA(r:Float,g:Float,b:Float,a:Float) -> UIColor {
    return UIColor.init(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a))
}

func MRect(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat) -> CGRect {
    return CGRect(x:x,y:y,width:width,height:height)
}

func ScaleWidth(value:CGFloat) -> CGFloat {
    return CGFloat(SCREEN_WIDTH/375) * value
}

//字体大小
func MFontWithSize(size:Float) -> UIFont {
    return UIFont.systemFont(ofSize: CGFloat(size))
}

//屏幕的宽高
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH = UIScreen.main.bounds.width

//适配iPhoneX
let is_iPhoneX = (SCREEN_WIDTH == 375.0 && SCREEN_HEIGHT == 812.0 ?true:false)
let NavBarH: CGFloat = is_iPhoneX ? 88.0 : 64.0
let BottomBarH: CGFloat = is_iPhoneX ? 34.0 : 0.0


//背景色
let MainBgColor = ColorFromRGBA(r: 243, g: 243, b: 243, a: 1)
//字体色
let TitleColor = ColorFromRGBA(r: 30, g: 30, b: 30, a: 1)
let DetailColor = ColorFromRGBA(r: 163, g: 163, b: 163, a: 1)

let disposebag = DisposeBag()

//通知
let RefreshContractListNotification = "RefreshContractListNotification"
let RefreshCalculatorDataNotification = "RefreshCalculatorDataNotification"
let UserInfoDidFetchNotification = "UserInfoDidFetchNotification"
let GotoLoginViewControllerNotification = "GotoLoginViewControllerNotification"
let AutoLoginNotification = "AutoLoginNotification"

//系统版本>11.0
func SYSTEM_VER_GREATER_11_0() -> Bool {
    if #available(iOS 11.0, *) {
        return true
    }
    return false
}

//请求接口
let BaseApi = "http://www.scanscan.net"




