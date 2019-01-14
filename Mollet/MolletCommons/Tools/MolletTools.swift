//
//  MolletTools.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/28.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

//所有的货币类型
let allCurrency = [
    "China",
    "Korea",
    "Japan",
    "Thailand",
    "Indonesia",
    "Malaysia",
    "Singapore",
    "India",
    "Philippines",
    "Vietnam",
    "Hong Kong",
    "Taiwan",
    "Israel",
    "Turkey",
    "EU countries",
    "USA",
    "Chile",
    "Argentina",
    "South Africa Republic",
    "Mexico",
    "Brazil"
]

class MolletTools {
    
    //根据国家获取货币类型
    class func getCurrencyFromCountry(country:String) -> String {
        //所有的货币类型

        //货币对应的国家名
        let allCopyCurrencyCountry = [
            "China",
            "Korea",
            "Japan",
            "Thailand",
            "Indonesia",
            "Malaysia",
            "Singapore",
            "India",
            "Philippines",
            "Vietnam",
            "Hong Kong",
            "Taiwan",
            "Israel",
            "Turkey",
            "EU countries",
            "United States",
            "Chile",
            "Argentina",
            "South Africa Republic",
            "Mexico",
            "Brazil"
        ]
        
        var type = "USA"
        for index in 0..<allCopyCurrencyCountry.count {
            let value = allCopyCurrencyCountry[index]
            if value == country {
                type = allCurrency[index]
            }
        }
        if country.contains("Korea") {
            type = "Korea"
        }
        return type
    }
    
    
    //根据合同类型、收支获取实际收入
    class func getWallet(jobIncome: Float, expense: Float, type:String, guarantee:String) -> Float {

        var wallet:Float = 0.0
        let jobSum = jobIncome
        if type == "Guarantee" {
            //保证金类型
            let G_add_C = Float(guarantee)! + Float(expense)
            if G_add_C > Float(jobSum) {
                //如果G+C>Job 所得为保证金的钱
                wallet = Float(guarantee)!
            }else {
                wallet = Float(jobSum) - Float(expense)
            }
        }else if type == "Percentage" {
            //百分比
            if jobSum >= Float(expense) {
                //收入大于支出
                print(jobSum)
                print(expense)
                wallet = Float(jobSum - Float(expense))
            }else {
                wallet = 0.0
            }
        }
        print("最终收入为\(wallet)")
        //四舍五入
        return roundf(wallet)
    }
    
    //计算时间差
    class func calculatorCountDownNum(endDateStr:String, isStartDate: Bool) -> Int {
        
        let dataFrormatter = DateFormatter.init(withFormat: "yyyy-MM-dd", locale: "")
        
        let endDate = dataFrormatter.date(from: endDateStr)
        let nowDate = Date()
        //计算相差天数
        let components = Calendar.current.dateComponents([.day], from: nowDate, to: endDate!)
        var day = components.day
        if isStartDate {
            //开始时间 始终结果为负 取绝对值
            return abs(day ?? 0)
        }else {
            //结束时间 如果如果为负 =0
            if day! < 0 {
                day = 0
            }
        }
        return day ?? 0
    }
    
    //判断传入时间是否过期
    class func dateIsOutOfNow(endDateStr: String) -> Bool {
        
        let dataFrormatter = DateFormatter.init(withFormat: "yyyy-MM-dd", locale: "")
        let endDate = dataFrormatter.date(from: endDateStr)
        let nowDate = Date()
        //计算相差天数
        let components = Calendar.current.dateComponents([.day], from: nowDate, to: endDate!)
        let day = components.day
        if day! < 0 {
            //过期即为完成
            return true
        }
        return false
    }
    
    //根据国家获取单位
    class func unitFromCountry(country: String) -> String {
        //获得该国的货币单位
        let Currency = MolletTools.getCurrencyFromCountry(country: country)
        //所有货币符号
        let currencySymbol = [
            "¥",
            "₩",
            "J¥",
            "฿",
            "Rp",
            "RM",
            "S$",
            "Rs.",
            "₱",
            "₫",
            "HK＄",
            "NT$",
            "₪‎",
            "₺",
            "€",
            "$",
            "CLP",
            "ARS$",
            "R",
            "MXN",
            "R$"
        ]
        var unit = "$"
        for i in 0..<allCurrency.count {
            let str = allCurrency[i]
            if Currency == str {
                unit = currencySymbol[i]
            }
        }
        return unit
    }
    
    //image -> base64字符串
    class func base64StringFromImage(image: UIImage) -> (String,UIImage) {
        
        //压缩图片尺寸 高度固定 宽度原比例缩放
        let scaleW = image.size.width/image.size.height * 200
        let scaleImage = image.scaleToSize(size: CGSize(width:scaleW,height:200))
        
        var imageData = UIImageJPEGRepresentation(scaleImage, 1)
        var size = CGFloat((imageData?.count)!) / 1024.0
        
        //调整大小
        var resizeRate = 0.5
        while size > 20 && resizeRate > 0 {
            //循环遍历 设置比例系数递减 判断尺寸是否符合
            imageData = UIImageJPEGRepresentation(scaleImage,CGFloat(resizeRate))
            size = CGFloat((imageData?.count)!) / 1024.0
            resizeRate -= 0.05
            print(size)
        }
        // image -> data
        let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let image1 = UIImage.init(data: imageData!)
        return (base64String,image1!)
    }
    
    //展示弹框
    //如果一个函数参数可能导致引用循环，那么它需要被显示地标记出来。@escaping标记可以作为一个警告，来提醒使用这个函数的开发者注意引用关系。
    class func alertController(msg:String ,_ okSelect:@escaping () -> ()) -> UIAlertController {
        let alertController = UIAlertController.init(title: "Warning!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction.init(title: "Confirm", style: UIAlertActionStyle.destructive, handler: { (_) in
            okSelect()
        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        return alertController
    }
    
    //是不是数字（带小数的）
    class func isFloat(string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        let scan: Scanner = Scanner(string: string)
        var val:Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }
    
}

//压缩图片到指定尺寸
extension UIImage {
    func scaleToSize(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
