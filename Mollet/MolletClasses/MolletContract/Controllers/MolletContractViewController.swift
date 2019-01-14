//
//  MolletContractViewController.swift
//  Mollet
//
//  Created by wml on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh


class MolletContractViewController: MolletBaseViewController {
    
    var contractView:MolletContractView!
    var tableView:UITableView!
    var viewModel:MolletContractViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //修改后返回重新获取
        if let profileUrl = UserDefaults.standard.value(forKey: "ProfilePicUrl") as? String {
            print(profileUrl)
            self.contractView.headerImage.sd_setImage(with: URL(string: profileUrl), placeholderImage: UIImage.init(named: "head-placeholder"))
        }
    }
    
    func bindViewModel() {
        viewModel = MolletContractViewModel(headerRefresh: self.tableView.mj_header.rx.refreshing.asDriver())
        
        _ = viewModel.contractList.bind(to: tableView.rx.items){ (tableView,row,element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MolletContractCell") as! MolletContractCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let model = element
            cell.contractName.text = model.Name
            let cityName = (model.City ?? "").count > 0 ? "\(model.City ?? "")，" : ""
            cell.address.text = "\(cityName)\(String(describing: model.Country ?? ""))"
            cell.startDate.text = model.StartDate ?? ""
            cell.endDate.text = model.EndDate ?? ""
            cell.statusText.text = model.status ?? ""
            let status = model.status ?? ""
            cell.statusIcon.image = (status == "Completed") ? UIImage.init(named: "status-finish") : UIImage.init(named: "status-working")
            return cell
        }
        
        //点击事件
        _ = tableView.rx.itemSelected.subscribe(onNext:{ (indexPath) in
            let model = self.viewModel.contractList.value[indexPath.row]
            print(model.Guarantee)
            let calcultorVC = MolletCalcultorViewController()
            calcultorVC.contractModel = model
            self.navigationController?.pushViewController(calcultorVC, animated: true)
        })
        
        //停止刷新绑定
        viewModel.endHeaderRefreshing
            .drive(self.tableView.mj_header.rx.endRefreshing)
            .disposed(by: disposebag)
        
        //检测登录状态
        viewModel.checkLogin {
            //去登录
            self.gotoLoginVC()
        }
        
        //修改合同、添加合同、通知
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(rawValue: RefreshContractListNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{[weak self]_ in
                //刷新列表
                self?.refreshContractList()
            })
        
        //跳转登录页
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(rawValue: GotoLoginViewControllerNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{[weak self]_ in
                //跳转登录
                self?.gotoLoginVC()
            })
        
        //用户信息获取完成 刷新头像信息
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(rawValue: UserInfoDidFetchNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext:{[weak self]_ in
                if let profileUrl = UserDefaults.standard.value(forKey: "ProfilePicUrl") as? String {
                    print(profileUrl)
                    self?.contractView.headerImage.sd_setImage(with: URL(string: profileUrl), placeholderImage: UIImage.init(named: "head-placeholder"))
                }
            })
    }
    
    //修改合同、添加合同、调用获取合同列表
    func refreshContractList() {
        MBProgressHUDSwift.showLoading()
        MolletContractViewModel.getContractList()
            .drive(onNext:{ (array: [MolletContractModel]) in
                self.viewModel.contractList.accept(array)
                MBProgressHUDSwift.dismiss()
            })
            .disposed(by: disposebag)
    }
    
    func setupSubviews() {
        self.view.backgroundColor = MainBgColor

        contractView = MolletContractView.init(frame: self.view.bounds)
        self.view.addSubview(contractView)
        self.navigationItem.titleView = contractView.titleView
        tableView = contractView.tableView
        _ = tableView.rx.setDelegate(self)
        
        //添加header点击事件
        let tap = UITapGestureRecognizer()
        contractView.headerImage.addGestureRecognizer(tap)
        _ = tap.rx.event.subscribe(onNext:{ [weak self] recognizer in
            self?.navigationController?.pushViewController(MolletPersonalCenterViewController(), animated: true)
        })
        //添加合同
        _ = contractView.addButton.rx.tap.subscribe(onNext:{
            let contractVC = MolletContractDetailViewController()
            contractVC.isContractEdit = false
            self.navigationController?.pushViewController(contractVC, animated: true)
            //为了解决左滑状态 如果跳转再返回时左滑编辑按钮消失
            self.tableView.reloadData()
        })
        
    }
    
    func gotoLoginVC() {
        let loginVC = MolletLoginViewController()
        let navigationVC = UINavigationController.init(rootViewController: loginVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置iOS11.0以后的左滑删除按钮
        if !SYSTEM_VER_GREATER_11_0() {
            return
        }
        var buttonArray = [UIButton]()
        for view in tableView.subviews {
            if view.isKind(of: NSClassFromString("UISwipeActionPullView")!) {
                for buttonView in view.subviews {
                    if buttonView.isKind(of: NSClassFromString("UISwipeActionStandardButton")!) {
                        let actionButton:UIButton = buttonView as! UIButton
                        actionButton.layer.masksToBounds = true
                        actionButton.frame = MRect(x: 0, y: 28, width: 92, height: 92)
                        //actionButton.titleEdgeInsets = UIEdgeInsetsMake(200, 0, 0, 0)
                        buttonArray.append(actionButton)
                    }
                }
            }
        }
        if buttonArray.count >= 2 {
            for i in 0..<buttonArray.count {
                let button:UIButton = buttonArray[i]
                if i%2 == 0 {
                    //设置编辑按钮
                    button.setImage(UIImage.init(named: "edite"), for: .normal)
                    button.setImage(UIImage.init(named: "edite"), for: .selected)
                    button.backgroundColor = ColorFromRGBA(r: 212, g: 212, b: 212, a: 1)
                }else {
                    //设置删除按钮
                    button.setImage(UIImage.init(named: "delete"), for: .normal)
                    button.setImage(UIImage.init(named: "delete"), for: .selected)
                    button.backgroundColor = ColorFromRGBA(r: 238, g: 31, b: 88, a: 1)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.mj_header.endRefreshing()
    }
}



//tableView代理实现
extension MolletContractViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var title = "            "
        if SYSTEM_VER_GREATER_11_0() {
            title = ""
        }
        let edite = UITableViewRowAction.init(style: .normal, title: title) { (action, indexpath) in
            print("点击了编辑")
            let contractEditVC = MolletContractDetailViewController()
            contractEditVC.isContractEdit = true
            contractEditVC.contractModel = self.viewModel.contractList.value[indexPath.row]
            self.navigationController?.pushViewController(contractEditVC, animated: true)
        }
        edite.backgroundColor = MainBgColor
        
        let delete = UITableViewRowAction.init(style: .normal, title: title) { (action, indexpath) in
//            print("点击了删除")
            let model = self.viewModel.contractList.value[indexPath.row]
            self.present(MolletTools.alertController(msg: "Confirm deletion?", {
                print("点击了确定")
                _ = self.viewModel.deleteContract(contractId: String(describing: model.ContractId!))
                    .subscribe(onNext:{ resp in
                        print(resp)
                        self.noticeOnlyText("Delete success!")
                        self.viewModel.deleteListData(model: model)
                    })
            }), animated: true, completion: nil)
        }
        delete.backgroundColor = MainBgColor
        return [delete, edite]
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.view.setNeedsLayout()
    }
}
