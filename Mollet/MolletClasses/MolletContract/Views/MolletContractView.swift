//
//  MolletJobView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletContractView: UIView {

    var headerImage:UIImageView!
    var titleView:UIView!
    var tableView:UITableView!
    var footerView:UIView!
    var addButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        titleView = UIView.init(frame: MRect(x: 0, y: 0, width: 300, height: 44))
        
        headerImage = UIImageView.init(frame: MRect(x: 0, y: 7, width: 30, height: 30))
        headerImage.layer.cornerRadius = 15
        headerImage.layer.masksToBounds = true
        headerImage.backgroundColor = UIColor.groupTableViewBackground
        headerImage.isUserInteractionEnabled = true
        headerImage.contentMode = UIViewContentMode.scaleAspectFill
        titleView.addSubview(headerImage)
        
        let titleLab = UILabel.init(frame: MRect(x: 40, y: 0, width: 220, height: 44))
        titleLab.font = UIFont.systemFont(ofSize: 20.0)
        titleLab.text = "Your contract"
        titleLab.textAlignment = NSTextAlignment.center
        titleView.addSubview(titleLab)
        
        tableView = UITableView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH-30, height: SCREEN_HEIGHT-NavBarH-BottomBarH))
        tableView.backgroundColor = MainBgColor
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 120
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UINib.init(nibName: "MolletContractCell", bundle: nil), forCellReuseIdentifier: "MolletContractCell")
        tableView.showsVerticalScrollIndicator = false
        self.addSubview(tableView)
        
        footerView = UIView()
        footerView.frame = MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 110)
        footerView.backgroundColor = MainBgColor
        tableView.tableFooterView = footerView
        
        addButton = UIButton()
        addButton.setBackgroundImage(UIImage.init(named: "button-black"), for: UIControlState.normal)
        addButton.setTitle("Add contract", for: UIControlState.normal)
        addButton.frame = MRect(x: 30, y: 30, width: SCREEN_WIDTH-60, height: ScaleWidth(value: 50))
        footerView.addSubview(addButton)
        
        setupRefresh()
    }
    
    func setupRefresh() {
        //设置头部刷新控件
        let headerRefresh = MJRefreshNormalHeader()
        headerRefresh.lastUpdatedTimeLabel.isHidden = true
        headerRefresh.stateLabel.isHidden = true
        self.tableView.mj_header = headerRefresh
    }

}
