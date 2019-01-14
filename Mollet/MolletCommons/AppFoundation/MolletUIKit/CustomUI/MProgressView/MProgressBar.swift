//
//  MProgressBar.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

/*
 * 直线进度条
 */
class MProgressBar: UIView {

    var value: Int = 0 {
        didSet {
            if value > 100 {
                value = 100
            }else if value < 0{
                value = 0
            }
        }
    }
    
    struct Constant {
        //起始渐变色
        static let startColor = UIColor.init(red: 156/255.0, green: 255/255.0, blue: 172/255.0, alpha: 1)
        //结束渐变色
        static let endColor = UIColor.init(red: 77/255.0, green: 216/255.0, blue: 99/255.0, alpha: 1)
        //进度条宽度
        static let lineWidth = CGFloat(4)
    }
    
    var gradientLayer:CAGradientLayer!
    var lookButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubviews() {
        //长度
        let length = self.frame.size.width
        
        //设置背景view
        let bgLayer = CALayer()
        bgLayer.frame = MRect(x: 0, y: self.frame.size.height/2-Constant.lineWidth/2, width: length, height: Constant.lineWidth)
        bgLayer.backgroundColor = UIColor.init(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1).cgColor
        bgLayer.cornerRadius = 2
        self.layer.addSublayer(bgLayer)
        
        //设置进度条view
        let gradientColors = [Constant.startColor.cgColor, Constant.endColor.cgColor]
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        //创建CAGradientLayer对象并设置参数
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        //设置渐变的方向 水平
        gradientLayer.startPoint = CGPoint(x:0,y:0.5)
        gradientLayer.endPoint = CGPoint(x:1,y:0.5)
        gradientLayer.cornerRadius = 2
        
        //设置其CAGradientLayer对象的frame，并插入view的layer
        gradientLayer.frame = MRect(x: 0, y: self.frame.size.height/2-Constant.lineWidth/2, width: 0, height: Constant.lineWidth)
        self.layer.addSublayer(gradientLayer)
        
        //设置lookButton
        lookButton = UIButton()
        lookButton.frame = MRect(x: -8, y: 5, width: 55, height: 28)
        lookButton.setImage(UIImage.init(named: "look"), for: .normal)
        self.addSubview(lookButton)
        
    }
    
    //设置进度条的值
    func setProgress(pro:Int) {
        value = pro
        //单位宽度
        let unit_w = self.frame.width/100
        let fact_w = unit_w * CGFloat(value)
        //设置gradientLayer坐标
        self.gradientLayer.frame = MRect(x: 0, y: self.frame.size.height/2-Constant.lineWidth/2, width: fact_w, height: Constant.lineWidth)
        //开始frame动画
        UIView.animate(withDuration: 0.5) { [weak self] in
            var btnX = -8 + fact_w
            if btnX > (self?.frame.width)! - 55 + 8 {
                btnX = (self?.frame.width)! - 55 + 8
            }
            self?.lookButton.frame = MRect(x: btnX, y: 5, width: 55, height: 28)
        }
    }

}
