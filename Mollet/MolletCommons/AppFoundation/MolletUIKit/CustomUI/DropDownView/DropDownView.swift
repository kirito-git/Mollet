//
//  DropDownView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/18.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

//点击代理
@objc protocol DropDownDelegate {
    func cellSelect(index: Int)
}

class DropDownView: UIView {
    //默认宽高
    let btn_w = 80
    let btn_h = 30
    let arrow_h = 10
    
    var topArrowImage:UIImageView!
    var contentView:UIView!
    var buttonView:UIView!
    //起始坐标
    var originPoint = CGPoint(x:0,y:0)
    var titleArray = [""]
    
    var delegate:DropDownDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
//        self.backgroundColor = ColorFromRGBA(r: 0, g: 0, b: 0, a: 0.3)
        setupSubviews()
        //自身添加点击事件
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        _ = tap.rx.event.subscribe(onNext:{ [weak self] recongizer in
            self?.hideDropDown()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupSubviews() {
        
        //contentView 三角 + 按钮
        if contentView == nil {
            contentView = UIView.init(frame: MRect(x: originPoint.x, y: originPoint.y, width: CGFloat(btn_w), height: 80))
        }
        contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        //设置锚点
        contentView.layer.anchorPoint = CGPoint(x:0.75,y:0)
        //设置阴影
        contentView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOpacity = 0.4
        self.addSubview(contentView)
        
        //顶部小三角
        if topArrowImage == nil {
            topArrowImage = UIImageView()
        }
        topArrowImage.image = UIImage.init(named: "arrow-up")
        contentView.addSubview(topArrowImage)
        
        //buttonView
        if buttonView == nil {
            buttonView = UIView()
        }
        buttonView.backgroundColor = UIColor.white
        buttonView.layer.cornerRadius = 6
        buttonView.layer.masksToBounds = true
        contentView.addSubview(buttonView)
        
        topArrowImage.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(-15)
            make.height.equalTo(arrow_h)
            make.width.equalTo(14)
        }
        
        buttonView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(arrow_h)
        }
    }
    
    func setButtonsWithArray(array:[String]) {
        //添加按钮
        for i in 0..<array.count {
            let button = UIButton.init(frame: MRect(x: 0, y: CGFloat(i * btn_h), width: CGFloat(btn_w), height: CGFloat(btn_h)))
            button.setTitle(array[i], for: .normal)
            button.setTitleColor(TitleColor, for: .normal)
            button.titleLabel?.font = MFontWithSize(size: 12)
            button.backgroundColor = UIColor.white
            button.tag = i+1
            button.addTarget(self, action: #selector(buttonSelect(sender:)), for: .touchUpInside)
            buttonView.addSubview(button)
            //分割线
            let line = UIView.init(frame: MRect(x: 0, y: CGFloat((i + 1) * btn_h-1), width: CGFloat(btn_w), height: 1))
            line.backgroundColor = MainBgColor
            buttonView.addSubview(line)
        }
    }
    
    func showDropDown(titles:[String] , point:CGPoint) {
        //根据数据创建按钮
        self.setButtonsWithArray(array: titles)
        //更新坐标
        originPoint = point
        titleArray = titles
        self.setNeedsLayout()
        //开始缩放动画
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    //移除view
    func hideDropDown() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.2
        }) { (_) in
            self.removeFromSuperview()
            self.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
    
    //按钮绑定事件
    @objc func buttonSelect (sender: UIButton) {
        self.hideDropDown()
        delegate?.cellSelect(index: sender.tag  - 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = MRect(x: originPoint.x, y: originPoint.y, width: CGFloat(btn_w), height: CGFloat(arrow_h + titleArray.count * btn_h))
    }
    
}
