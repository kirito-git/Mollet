//
//  RulerView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/18.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class RulerView: UIView ,UIScrollViewDelegate {

    var scrollView:UIScrollView!
    var contentView:UIView!
    var centerLine:UIView!
    var rulerNum = 120.0
    var perValue = 500 //每格代表的数值
    let contentWidth = SCREEN_WIDTH-60
    
    //绿色
    let greenColor = ColorFromRGBA(r: 77, g: 216, b: 99, a: 1)
    //红色
    let redColor = ColorFromRGBA(r: 241, g: 24, b: 85, a: 1)
    
    @objc dynamic var currentColor:UIColor!
    /*
     * Objective-C 对象是基于运行时以及动态派发，在运行调用时再决定实际调用的具体实现
     * Swift 类型的成员或者方法在编译时就已经决定，而运行时便不再需要经过一次查找，而可以直接使用。
     */
    //结果 使用kvo监听此属性要使用 @objc dynamic var
    //KVO 是基于 KVC (Key-Value Coding) 以及动态派发技术实现的，而这些东西都是 Objective-C 运行时的概念
    //Swift 为了效率，默认禁用了动态派发，因此想用 Swift 来实现 KVO，我们需要将想要观测的对象标记为 dynamic
    @objc dynamic var resultValue = "0$"
    
    /* 内容宽度为 screenWidth - 30 * 2
     *  左右两边各留内容宽度一半 即 空白宽度占一个内容宽度
     *  一个内容宽度有60格，总共120格
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubviews() {
        
        currentColor = greenColor
        
        scrollView = UIScrollView.init(frame: CGRect(x:30,y:0,width:contentWidth,height:100))
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width:contentWidth*3,height:100)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = false
        self.addSubview(scrollView)
        
        contentView = UIView.init(frame: CGRect(x:0,y:0,width:contentWidth*3,height:100))
        //contentView.backgroundColor = UIColor.yellow
        scrollView.addSubview(contentView)
        
        centerLine = UIView()
        centerLine.frame = CGRect(x:SCREEN_WIDTH/2.0,y:65,width:1,height:35)
        centerLine.backgroundColor = currentColor
        self.addSubview(centerLine)
        
        self.setRulerLayer()
        
        //设置默认偏移为中心
        self.setRulerValue(value: 0)
        //scrollView.setContentOffset(CGPoint(x:contentWidth,y:0), animated: true)
    }
    
    func setRulerLayer() {
        //水平间距
        let horizontal = contentWidth * 2 / CGFloat(rulerNum)
        //创建刻度layer
        for i in 0..<Int(rulerNum) {
            let layer = CALayer()
            var frame = CGRect(x:horizontal * CGFloat(i) + contentWidth/2.0,y:92,width:1,height:8)
            if i % 10 == 0 {
                frame = CGRect(x:horizontal * CGFloat(i) + contentWidth/2.0,y:84,width:1,height:16)
                //同时还要创建刻度值label
                let numLab = UILabel()
                numLab.frame = CGRect(x:horizontal * CGFloat(i) + contentWidth/2.0 - 20,y:72,width:40,height:12)
                numLab.text = String(( i - 60) * Int(perValue))
                numLab.textAlignment = .center
                numLab.font = UIFont.systemFont(ofSize: 10)
                numLab.textColor = ColorFromRGBA(r: 231, g: 231, b: 231, a: 1)
                contentView.addSubview(numLab)
            }
            layer.frame = frame
            layer.backgroundColor = UIColor.init(red: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1).cgColor
            contentView.layer.addSublayer(layer)
        }
    }
    
    func setPerValueWithOriginValue(value: String) {
        
        let wallat = Float(value)!
        let ll = wallat/30000
        print(floor(ll))
        perValue = Int((1 + ll) * 1000)
//        if wallat < Float(30000) && wallat > Float(-30000) {
//            perValue = 1000
//        }else if wallat < Float(60000) && wallat > Float(-60000) {
//            perValue = 2000
//        }else if wallat < Float(90000) && wallat > Float (-90000) {
//            perValue = 3000
//        }else if wallat < Float(210000) && wallat > Float (-210000) {
//            perValue = 6000
//        }else if wallat < Float(300000) && wallat > Float(-300000) {
//            perValue = 9000
//        }else {
//            perValue = 10000
//        }
        
        //移除
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        //创建
        setRulerLayer()
    }
    
    //scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //默认初始从一半开始
        let contentOffsetX = scrollView.contentOffset.x - contentWidth/2.0
        //一格的偏移量
        let oneRuler = contentWidth * 2 / CGFloat(rulerNum)
        //这里要加上contentWidth宽的一半 因为刻度在中点
        let num = ceilf(Float((contentOffsetX + contentWidth / 2.0) / oneRuler))
        resultValue = String(format:"%g",(num - 60) * Float(perValue))
        //print(resultValue)
        
        //负数设置为红色
        currentColor = num < 60 ? redColor : greenColor
        if centerLine != nil {centerLine.backgroundColor = currentColor}
    }
    
    //根据指定的值来设置scroll的偏移
    func setRulerValue(value:CGFloat) {
        //格数
        let ruler = value / CGFloat(perValue) + 60
        //一格的偏移量
        let oneRuler = contentWidth * 2.0 / CGFloat(rulerNum)
        //总的偏移量
        let contentOffSetX = ruler * oneRuler
        //设置scrollview偏移量
        scrollView.setContentOffset(CGPoint(x:contentOffSetX,y:0), animated: true)
    }

    
    
}
