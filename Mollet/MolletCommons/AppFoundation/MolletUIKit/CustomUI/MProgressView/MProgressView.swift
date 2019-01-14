//
//  MProgressView.swift
//  circle
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

/*
 * 圆形进度条
 */
class MProgressView: UIView {

    var valueLab:UILabel!
    var tipLab:UILabel!
    
    struct Constant {
        //进度条宽度
        static let lineWidth: CGFloat = 8
        //进度槽颜色
        static let trackColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0,alpha: 1)
        //进度条颜色
        static let progressColoar = UIColor.init(red: 77/255.0, green: 216/255.0, blue: 99/255.0, alpha: 1)
    }
    
    //进度槽
    let trackLayer = CAShapeLayer()
    //进度条
    let progressLayer = CAShapeLayer()
    //进度条路径（整个圆圈）
    let path = UIBezierPath()
    
    //当前进度
    var progress: Float = Float(0) {
        didSet {
            if progress > 100 {
                progress = Float(100)
            }else if progress < 0 {
                progress = Float(0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupLabels()
    }

    override func draw(_ rect: CGRect) {
        //获取整个进度条圆圈路径
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                    radius: bounds.size.width/2 - Constant.lineWidth,
                    startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        
        //绘制进度槽
        trackLayer.frame = bounds
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = Constant.trackColor.cgColor
        trackLayer.lineWidth = Constant.lineWidth
        trackLayer.path = path.cgPath
        layer.addSublayer(trackLayer)
        
        //绘制进度条
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = Constant.progressColoar.cgColor
        progressLayer.lineWidth = Constant.lineWidth
        progressLayer.path = path.cgPath
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        layer.addSublayer(progressLayer)
    }
    
    //设置进度（可以设置是否播放动画）
    func setProgress(_ pro: Float,animated anim: Bool) {
        setProgress(pro, animated: anim, withDuration: 0.55)
    }
    
    //设置进度（可以设置是否播放动画，以及动画时间）
    func setProgress(_ pro: Float,animated anim: Bool, withDuration duration: Double) {
        progress = pro
        //进度条动画
        CATransaction.begin()
        CATransaction.setDisableActions(!anim)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut))
        CATransaction.setAnimationDuration(duration)
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        CATransaction.commit()
        //设置数值
        valueLab.text = "\(String(format:"%g",pro))%"
    }
    
    //将角度转为弧度
    fileprivate func angleToRadian(_ angle: Double)->CGFloat {
        return CGFloat(angle/Double(180.0) * M_PI)
    }
    
    //label
    func setupLabels() {
        //值label
        valueLab = UILabel()
        valueLab.frame = CGRect(x:Constant.lineWidth+2,y:bounds.midY-20,width:self.frame.size.width-(Constant.lineWidth+2)*2,height:24)
        valueLab.font = UIFont.boldSystemFont(ofSize: ScaleWidth(value: 18))
        valueLab.textColor = UIColor.init(red: 77/255.0, green: 216/255.0, blue: 99/255.0, alpha: 1)
        valueLab.textAlignment = .center
        valueLab.text = "0%"
        valueLab.adjustsFontSizeToFitWidth = true
        self.addSubview(valueLab)
        
        //提示label
        tipLab = UILabel()
        tipLab.frame = CGRect(x:Constant.lineWidth+2,y:bounds.midY+5,width:bounds.width-(Constant.lineWidth+2)*2,height:12)
        tipLab.font = UIFont.systemFont(ofSize: ScaleWidth(value: 10))
        tipLab.textColor = UIColor.init(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1)
        tipLab.textAlignment = .center
        tipLab.text = "Catalog"
        self.addSubview(tipLab)
    }
    
}
