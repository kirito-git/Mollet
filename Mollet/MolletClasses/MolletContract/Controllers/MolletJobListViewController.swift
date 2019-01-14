//
//  MolletJobListViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletJobListViewController: MolletBaseViewController {

    var jobListView:MolletJobListView!
    var tableView:UITableView!
    var viewModel:MolletJobListViewModel!
    
    var contractModel:MolletContractModel?
    
    var unit:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle = "Job List"
        setupSubviews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //每次返回请求一次
        _ = MolletJobListViewModel.getJobListRequest(contractId: (self.contractModel?.ContractId)?.description ?? "")
        .drive(onNext:{ models in
            self.viewModel.jobList.accept(models)
        }).disposed(by: disposebag)
    }
    
    func setupSubviews() {
        jobListView = MolletJobListView.init(frame: CGRect.zero)
        self.view.addSubview(jobListView)
        self.tableView = jobListView.tableView
        self.tableView.rx.setDelegate(self)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }
    
    func bindViewModel() {
        
        viewModel = MolletJobListViewModel(headerRefresh:self.tableView.mj_header.rx.refreshing.asDriver(),contractId:(self.contractModel?.ContractId)?.description ?? "")
        
        //货币单位
        let country = self.contractModel?.Country ?? ""
        unit = MolletTools.unitFromCountry(country: country)
        
        _ = viewModel.jobList.bind(to: self.tableView.rx.items){ (tableView,row,model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MolletJobListCell") as! MolletJobListCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.name.text = model.Name ?? ""
            cell.date.text = model.Date ?? ""
            let timeUnit = (model.JType! == "Show" || model.JType == "Event") ? "days" : "hours"
            cell.duration.text = "\(model.Hours ?? "0") \(timeUnit)"
            var price = "0"
            let percentage = self.contractModel?.Percentage ?? 0
            if let hours = model.Hours,let hourlyPay = model.HourlyPay {
                let value = Float(hours)! * Float(hourlyPay)! * Float(percentage) / Float(100)
                price = "\(self.unit!)\(String(describing: value))"
            }
            cell.price.text = price
            return cell
        }
        
        //停止刷新
        viewModel.endHeaderRefreshing
            .drive(self.tableView.mj_header.rx.endRefreshing)
            .disposed(by: disposebag)
    }
    
    //更新数据后返回 请求一次
    func refreshRequest() {
        MolletJobListViewModel.getJobListRequest(contractId: (self.contractModel?.ContractId)?.description ?? "")
            .drive(onNext:{ models in
                self.viewModel.jobList.accept(models)
            }).disposed(by: disposebag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                        actionButton.frame = MRect(x: 0, y: 0, width: 92, height: 92)
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
                    button.backgroundColor = ColorFromRGBA(r: 212, g: 212, b: 212, a: 1)
                }else {
                    //设置删除按钮
                    button.setImage(UIImage.init(named: "delete"), for: .normal)
                    button.backgroundColor = ColorFromRGBA(r: 238, g: 31, b: 88, a: 1)
                }
            }
        }
    }

}

//taleview代理
extension MolletJobListViewController : UITableViewDelegate ,DZNEmptyDataSetDelegate ,DZNEmptyDataSetSource {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var title = "            "
        if SYSTEM_VER_GREATER_11_0() {
            title = ""
        }
        let edite = UITableViewRowAction.init(style: .normal, title: title) { (action, indexpath) in
            print("点击了编辑")
            let model = self.viewModel.jobList.value[indexPath.row]
            let jobEditeVC = MolletJobAddViewController()
            jobEditeVC.isJobEdit = true
            jobEditeVC.jobModel = model
            jobEditeVC.contractModel = self.contractModel
            self.navigationController?.pushViewController(jobEditeVC, animated: true)
        }
        edite.backgroundColor = MainBgColor
        
        let delete = UITableViewRowAction.init(style: .normal, title: title) { (action, indexpath) in
            let model = self.viewModel.jobList.value[indexPath.row]
            self.present(MolletTools.alertController(msg: "Confirm deletion?", {
                print("点击了确定")
                MBProgressHUDSwift.showLoading()
                _ = self.viewModel.deleteJobRequest(jobId: String(describing: model.JobId!))
                    .subscribe(onNext:{ resp in
                        print(resp)
                        MBProgressHUDSwift.dismiss()
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
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "empty")
    }
}
