//
//  DateView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

@objc protocol DateViewDelegate {
    func selectDateString(dateString:String, timestamp:Double)
}

class DateView: UIView {

    //选择完成block
    //声明闭包
    typealias finishSelectBlock = (_ dateString : String? , _ timestamp:Double) -> ()
    var finishBlock:finishSelectBlock?
    
    var dateContentView:UIView!
    var datePicker:UIDatePicker!
    var delegate:DateViewDelegate?
    
    var isShowTime = false
    
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubviews() {
        self.isHidden = true
        //添加点击手势
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        _ = tap.rx.event.subscribe(onNext:{ [weak self] recongizer in
            self?.hidePresentView()
        })
    }
    
    func showDatePicker(showTime: Bool) {
        self.isHidden = false
        isShowTime = showTime
        
        self.backgroundColor = ColorFromRGBA(r: 0, g: 0, b: 0, a: 0.4)
        dateContentView = UIView.init(frame: MRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 350))
        dateContentView.backgroundColor = MainBgColor
        self.addSubview(dateContentView)
        //展示动画
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.dateContentView.frame = MRect(x: 0, y: SCREEN_HEIGHT-350, width: SCREEN_WIDTH, height: 350)
        }, completion: nil)
        
        
        //设置datepicker
        datePicker = UIDatePicker.init(frame: MRect(x: 0, y: 50, width: SCREEN_WIDTH, height: 200))
        if showTime == true {
            datePicker.datePickerMode = .dateAndTime
        }else {
            datePicker.datePickerMode = .date
        }
        dateContentView.backgroundColor = MainBgColor
        dateContentView.addSubview(datePicker)
        
        
        let leftButton = UIButton.init(frame: MRect(x: 15, y: 10, width: 80, height: 40))
        leftButton.setTitle("Cancel", for: .normal)
        leftButton.setTitleColor(DetailColor, for: .normal)
        leftButton.titleLabel?.font = MFontWithSize(size: 14)
        leftButton.tag = 1
        leftButton.addTarget(self, action: #selector(buttonSelect(sender:)), for: .touchUpInside)
        dateContentView.addSubview(leftButton)
        
        
        let dateConfirmBtn = UIButton.init(frame: MRect(x: SCREEN_WIDTH-80-15, y: 10, width: 80, height: 40))
        dateConfirmBtn.setTitle("Confirm", for: .normal)
        dateConfirmBtn.setTitleColor(TitleColor, for: .normal)
        dateConfirmBtn.titleLabel?.font = MFontWithSize(size: 14)
        dateConfirmBtn.tag = 2
        dateConfirmBtn.addTarget(self, action: #selector(buttonSelect(sender:)), for: .touchUpInside)
        dateContentView.addSubview(dateConfirmBtn)
        
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    
    @objc func buttonSelect(sender:UIButton) {
        self.hidePresentView()
        if sender.tag == 2 {
            //点击了确定
            let date = datePicker.date
            //创建dateFormatter
            let dateFormatter = DateFormatter.init()
            if isShowTime == true {
                //年月日时分秒
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }else {
                //年月日
                dateFormatter.dateFormat = "yyyy-MM-dd"
            }
            //时间字符串
            let dateString = dateFormatter.string(from: date)
            //时间戳
            let timestamp = date.timeIntervalSince1970
            delegate?.selectDateString(dateString: dateString, timestamp: timestamp)
            
            if finishBlock != nil{
                finishBlock!(dateString, timestamp)
            }
        }
    }

    //隐藏日期选择
    func hidePresentView() {
        if (self.dateContentView == nil) {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.dateContentView.frame = MRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 350)
        }) { (_) in
            self.dateContentView.removeFromSuperview()
            self.dateContentView = nil
            self.isHidden = true
        }
    }
}
