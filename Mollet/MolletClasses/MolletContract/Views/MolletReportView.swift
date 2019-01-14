//
//  MolletReportView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MolletReportView: UIView {

    //圆形进度tips
    var progressTips = ["Catalog","Event","Show","TVC","Video AD","Others"]

    //状态显示
    var statusButton:UIButton!
    
    var tableView:UITableView!
    //存放圆形进度条views
    var progressArray:[MProgressView]!
    //收入值label
    var earningPriceLab:UILabel!
    //百分比progressview
    var earningProgressBar:MProgressBar!
    //百分比文字
    var earningProgressTip:UILabel!
    //leftDays
    var leftDaysLab:UILabel!
    //look 查看排名按钮
    var lookButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.backgroundColor = MainBgColor
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubviews() {
        tableView = UITableView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-NavBarH-BottomBarH))
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = MainBgColor
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 120
        tableView.register(UINib.init(nibName: "MolletReportCell", bundle: nil), forCellReuseIdentifier: "MolletReportCell")
        self.addSubview(tableView)
        
        //设置头部
        setMyTableHeaderView()
    }
    
    func setMyTableHeaderView() {
        //head
        let headerView = MolletReportHeader.instanceReportHeader()
        headerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        headerView.frame = MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 444)
        headerView.backgroundColor = UIColor.white
        tableView.tableHeaderView = headerView
        
        //圆形进度
        let top_y = CGFloat(50)
        let h_space = ScaleWidth(value: 30)
        let width = ScaleWidth(value: 85)
        
        progressArray = [MProgressView]()
        for i in 0..<6 {
            let x = CGFloat(i%3) * (h_space + width) + h_space
            let y = CGFloat(i/3) * (CGFloat(width) + CGFloat(20)) + top_y
            let progressView = MProgressView.init(frame: MRect(x: x, y: y, width: width, height: width))
            progressView.tipLab.text = progressTips[i]
            headerView.addSubview(progressView)
            progressView.setProgress(0, animated: false, withDuration: 1)
            progressArray.append(progressView)
        }
        
        //圆形进度底部的y坐标
        let progressBottomY = top_y + CGFloat((20+width)*2)
        headerView.earningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(progressBottomY)
        }
        
        //设置条形进度条
        let pBarSuperView = headerView.earningProgressView
        let progressBar = MProgressBar.init(frame: (pBarSuperView?.bounds)!)
        pBarSuperView?.addSubview(progressBar)
        //progressBar.setProgress(pro: 80)
        
        //重新设置header的frame
        headerView.frame = MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: progressBottomY + 202)
        
        headerView.statusButton.setBackgroundImage(UIImage.init(named: "redBg"), for: UIControlState.normal)
        headerView.statusButton.setBackgroundImage(UIImage.init(named: "greenBg"), for: UIControlState.selected)
        headerView.statusButton.setTitle("Processing", for: .normal)
        headerView.statusButton.setTitle("Completed", for: .selected)
        headerView.statusButton.isSelected = false
        
        //将view接口暴露出去
        statusButton = headerView.statusButton
        earningPriceLab = headerView.earningValueLabel
        earningProgressBar = progressBar
        earningProgressTip = headerView.earningTipLabel
        leftDaysLab = headerView.leftDaysLabel
        lookButton = progressBar.lookButton
    }
    
    //设置6个进度条的数据
    func setSixProgressData(array:[String]) {
        for i in 0..<array.count {
            let value = array[i]
            if i < self.progressArray.count {
                let progressView = self.progressArray[i]
                print(value)
                progressView.setProgress(Float(value)!, animated: true)
            }
        }
    }

}
