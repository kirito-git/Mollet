//
//  MolletJobListView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletJobListView: UIView {

    var tableView:UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.backgroundColor = MainBgColor
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubviews() {
        tableView = UITableView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH-30, height: SCREEN_HEIGHT-NavBarH-BottomBarH))
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = MainBgColor
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 120
        tableView.register(UINib.init(nibName: "MolletJobListCell", bundle: nil), forCellReuseIdentifier: "MolletJobListCell")
        self.addSubview(tableView)
        //head
        let headerView = UIView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 15))
        headerView.backgroundColor = MainBgColor
        tableView.tableHeaderView = headerView
        
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
