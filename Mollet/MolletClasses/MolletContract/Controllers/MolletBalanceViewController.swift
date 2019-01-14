//
//  MolletBalanceViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

class MolletBalanceViewController: MolletBaseViewController ,DropDownDelegate, UIScrollViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var tableView: UITableView!
    var addButton:UIButton!
    var okButton:UIButton!
    var dropView:DropDownView!
    
    var viewModel:MolletBalanceViewModel!
    var contractVM:MolletContractDetailViewModel!
    //是否是编辑
    var isContractEdit: Bool?
    var contractModel:MolletContractModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle = "Balance List"
        setupSubviews()
        bindViewModel()
        otherMethod()
    }
    
    func bindViewModel() {
        viewModel = MolletBalanceViewModel()
        viewModel.setInitDataWithType(type: self.contractVM.contractType.value)
        viewModel.contractId.value = String(describing: contractModel?.ContractId ?? 0)
        
        //设置单位
        var unit:String?
        let country = self.contractVM.country.value
        unit = MolletTools.unitFromCountry(country: country)
        
        _ = viewModel.balanceList.bind(to: self.tableView.rx.items) { [weak self](tableView,row,model)  in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MolletBalanceCell") as! MolletBalanceCell
            cell.unitLab.text = self?.viewModel.unitAtIndex(row: row, originUnit: unit!)
            cell.deleteButton.isHidden = !(self?.viewModel.isShowDeleteButton(row: row))!
            cell.titleLab.text = model.title ?? ""
            cell.dateType.text = model.dateType ?? ""
            cell.inputTf.text = model.tfValue ?? ""
            cell.inputTf.placeholder = "0"
            cell.inputTf.tag = 10 + row
            cell.deleteButton.tag = row
            //选择日期类型点击
            _ = cell.dateTypeButton.rx.tap.subscribe(onNext:{ [weak self] in
                self?.showDateTypeView(row:row)
            })
            //删除点击
            _ = cell.deleteButton.rx.tap.asDriver()
                .drive(onNext: { [weak self] in
                self?.viewModel.deleteBalanceAtRow(row: row)
            }).disposed(by: cell.disposeBag)
            return cell
        }
        //添加点击
        _ = addButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.viewModel.addBalance()
        })
        
        //添加合同点击
        let okButtonClickVaild = okButton.rx.tap
            .throttle(0.6, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .flatMap{[weak self] _ -> Observable<Bool> in
                (self?.viewModel.inputValueReset())!
            }
            .filter({ vaild in
                return vaild
            })
            
        if isContractEdit == true {
            //编辑
            //获取默认值
            self.viewModel.fetchFeesList()
            
            //编辑
            _ = okButtonClickVaild
                .flatMapLatest{[weak self] isedit -> Observable<[String:Any]> in
                    (self?.viewModel.updateContractRequest(VM: (self?.contractVM)!))!
            }
            .subscribe(onNext:{ [weak self] response in
                print(response)
                MBProgressHUDSwift.dismiss()
                self?.noticeOnlyText("Update successfully!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshContractListNotification), object: nil)
                //修改收支
                MBProgressHUDSwift.showLoading()
                _ = self?.viewModel.updateBalanceInfo()
                    .subscribe(onNext:{ _ in
                        MBProgressHUDSwift.dismiss()
                        self?.navigationController?.popToRootViewController(animated: true)
                    })
            })
        }else {
            //创建
            _ = okButtonClickVaild
            .flatMapLatest{ [weak self] isedit -> Observable<[String:Any]> in
                (self?.viewModel.addContractRequest(VM: (self?.contractVM)!))!
            }
            .subscribe(onNext:{ [weak self] response in
                print(response)
                MBProgressHUDSwift.dismiss()
                self?.noticeOnlyText("Created successfully!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshContractListNotification), object: nil)
                //添加收支
                if let dataDic = response["result"] as? [String:Any] {
                    self?.viewModel.contractId.value = String(describing: dataDic["ContractId"] ?? 0) as! String
                }
                MBProgressHUDSwift.showLoading()
                _ = self?.viewModel.addBalanceInfo()
                    .subscribe(onNext:{ _ in
                        MBProgressHUDSwift.dismiss()
                        self?.noticeOnlyText("Created successfully!")
                        self?.navigationController?.popToRootViewController(animated: true)
                    })
            })
            
        }
        
    }
    
    
    func setupSubviews() {
        //头部10像素间隔
        let tableHeader = UIView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 10))
        tableHeader.backgroundColor = MainBgColor
        self.tableView.tableHeaderView = tableHeader
        //配置tableview
        //设置estimatedRowHeight 会推测高度，此处为了防止添加cell之后tableView偏移量发生变化
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = 80
        self.tableView.register(UINib.init(nibName: "MolletBalanceCell", bundle: nil), forCellReuseIdentifier: "MolletBalanceCell")
        //底部添加按钮
        let footerview = UIView.init(frame: MRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 210))
        footerview.backgroundColor = UIColor.white
        addButton = UIButton.init(frame: MRect(x: SCREEN_WIDTH/2-25, y: 20, width: 50, height: 50))
        addButton.setImage(UIImage.init(named: "balance_add"), for: .normal)
        footerview.addSubview(addButton)
        //灰色背景
        let grayView = UIView.init(frame: MRect(x: 0, y: 100, width: SCREEN_WIDTH, height: 110))
        grayView.backgroundColor = MainBgColor
        footerview.addSubview(grayView)
        //OK按钮
        okButton = UIButton.init(frame: MRect(x: 30, y: 20, width: SCREEN_WIDTH-60, height: ScaleWidth(value:50)))
        okButton.setBackgroundImage(UIImage.init(named: "button-black"), for: .normal)
        okButton.setTitle("OK", for: .normal)
        grayView.addSubview(okButton)
        self.tableView.tableFooterView = footerview
    }
    
    func otherMethod() {
        //注册textfiled文本改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotifi), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
    }
    
    @objc func receiveNotifi(noti:NSNotification) {
        let textfiled = noti.object as! UITextField
        self.viewModel.setTfValueWidthTextFiled(tf: textfiled)
    }
    
    //展示时间选择alertView
    func showDateTypeView(row:Int) {
        viewModel.dropviewSelectRow.value = row
        //计算初始坐标
        let currentCellY = row * 80
        let tableOffsetY = self.tableView.contentOffset.y
        //箭头的下方y坐标
        let arrowY = 70
        //显示的view的y坐标
        var typeViewY = CGFloat(currentCellY) - CGFloat(tableOffsetY) + CGFloat(arrowY)
        let typeViewX = ScaleWidth(value: 250)
        
        if typeViewY > SCREEN_HEIGHT-NavBarH-BottomBarH-80 {
            let originY = self.tableView.contentOffset.y + 210
            self.tableView.setContentOffset(CGPoint(x:0,y:originY), animated: false)
            
            typeViewY = typeViewY - 210
        }
        print(typeViewY)
        
        //展示下拉选项
        if dropView == nil {
            dropView = DropDownView()
        }
        dropView.delegate = self
        self.view.addSubview(dropView)
        dropView.showDropDown(titles: ["Weekly","Monthly","Onetime"], point: CGPoint(x:typeViewX,y:typeViewY))
    }
    
    // DropViewDelegate
    func cellSelect(index: Int) {
        let typeArray = ["Weekly","Monthly","Onetime"]
        viewModel.dateTypeChose(type: typeArray[index])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //移除通知
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    deinit {
        print("无循环引用")
        //移除通知
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
