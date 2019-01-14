//
//  CountryAndCityView.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/26.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol CountryAndCityViewDelegate {
    func CountryAndCityViewSelect(indexStr: String, dic:[String:Any], isCity:Bool)
}

class CountryAndCityView: UIView, UITableViewDelegate, UITableViewDataSource {

    var delegate:CountryAndCityViewDelegate?
    //初始化tableview索引数据
    var dataSource : [String] = [
        "A", "B", "C", "D", "E", "F", "G",
        "H", "I", "J", "K", "L", "M", "N",
        "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"]
    
    var countryDatas:[[[String:Any]]]!
    var cityDatas:[[String]]!
    var contentView:UIView!
    var countryTableView:UITableView!
    var isCity = false
    
    override init(frame: CGRect) {
        super.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.isHidden = true
        let bgButton = UIButton.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        _ = bgButton.rx.tap.subscribe(onNext:{ [weak self] recongizer in
            self?.hidePresentView()
        })
        self.addSubview(bgButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //隐藏dateContentView
    func hidePresentView() {
        if (self.contentView == nil) {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.frame = MRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 350)
        }) { (_) in
            self.contentView.removeFromSuperview()
            self.contentView = nil
            self.isHidden = true
        }
    }
    
    //显示国家选择
    func showCountryOrCityView(isCity:Bool,country:String) {
        
        self.isCity = isCity
        //初始化数组
        countryDatas = [[[String:Any]]]()
        cityDatas = [[String]]()
        self.isHidden = false
        setupSubviews()
        //设置国家列表数据
        if self.isCity == false {
            let tuple = CountryTools.getCountryDatas()
            countryDatas = tuple.0
            dataSource = tuple.1
        }else {
            let tuple = CountryTools.getCityDatas(country: country)
            cityDatas = tuple.0
            dataSource = tuple.1
        }
        countryTableView.reloadData()
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func setupSubviews() {
        //初始化背景view
        self.backgroundColor = UIColor.clear
        contentView = UIView.init(frame: MRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 350))
        contentView.backgroundColor = MainBgColor
        contentView.backgroundColor = UIColor.black
        self.addSubview(contentView)
        
        //展示动画
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.contentView.frame = MRect(x: 0, y: 150, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-150)
        }, completion: nil)
        
        //创建列表
        if countryTableView == nil {
            countryTableView = UITableView()
        }
        countryTableView.frame = MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: contentView.frame.size.height)
        countryTableView.tableFooterView = UIView()
        countryTableView.backgroundColor = UIColor.clear
        countryTableView.delegate = self
        countryTableView.dataSource = self
        countryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        countryTableView.sectionIndexColor = UIColor.white
        countryTableView.sectionIndexBackgroundColor = UIColor.clear
        countryTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        countryTableView.rowHeight = 40
        contentView.addSubview(countryTableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCity == false {
            return countryDatas[section].count
        }
        let array = cityDatas[section] 
        return array.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isCity == false {
            return countryDatas.count
        }
        return cityDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if self.isCity == false {
            let item = countryDatas[indexPath.section][indexPath.row]
            cell.textLabel?.text = "\(item["name"] as! String)"
        }else {
            let array = cityDatas[indexPath.section]
            cell.textLabel?.text = "\(array[indexPath.row])"
        }
        
        cell.textLabel?.font = MFontWithSize(size: 12)
        cell.textLabel?.textColor = UIColor.white
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    //实现索引数据源代理方法
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSource as? [String]
    }
    
    //点击索引，移动TableView的组位置
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var tpIndex:Int = 0
        //遍历索引值
        for character in dataSource {
            //判断索引值和组名称相等，返回组坐标
            if character as! String == title {
                return tpIndex
            }
            tpIndex += 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.black
        let label = UILabel.init(frame: MRect(x: 15, y: 0, width: 100, height: 30))
        label.text = dataSource[section] as? String
        label.font = MFontWithSize(size: 16)
        label.textColor = UIColor.white
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item:[String:Any]!
        var name:String!
        if self.isCity == false {
            //国家
            item = countryDatas[indexPath.section][indexPath.row]
            name = "\(item["name"] as! String)"
        }else {
            //城市
            let city = cityDatas[indexPath.section][indexPath.row]
            item = ["name":city]
            name = city
        }
        self.delegate?.CountryAndCityViewSelect(indexStr: name, dic: item, isCity: self.isCity)
        self.hidePresentView()
    }
}
