//
//  MolletReportViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletReportViewController: MolletBaseViewController {

    var reportView:MolletReportView!
    var tableView:UITableView!
    var viewModel:MolletReportViewModel!
    
    var unit:String?
    var calcultorVM:MolletCalcultorViewModel?
    var contractModel:MolletContractModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle = "Report"
        setupSubviews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //工作列表
        MBProgressHUDSwift.showLoading()
        viewModel.getJobListRequest()
    }
    
    func setupSubviews() {
        reportView = MolletReportView.init(frame: CGRect.zero)
        self.view.addSubview(reportView)
        self.tableView = reportView.tableView
    }
    
    func bindViewModel() {
        
        viewModel = MolletReportViewModel()
        viewModel.setReportDataFromPassingValue(viewmodel: self.calcultorVM!)
        //状态
        _ = viewModel.isComplete.asObservable().bind(to: self.reportView.statusButton.rx.isSelected)
        //6个圆形进度条数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reportView.setSixProgressData(array: self.viewModel.progressArray.value)
        }
        //earning
        let valletValue = self.calcultorVM!.wallet.value
        self.viewModel.earningValue.value = "\(self.unit!)\(valletValue)"
        _ = viewModel.leftdays.asObservable()
            .map{"\($0) days"}
            .bind(to: self.reportView.leftDaysLab.rx.text)
        _ = viewModel.earningValue.asObservable().bind(to: self.reportView.earningPriceLab.rx.text)
      
        _ = viewModel.countryRate.asObservable()
            .subscribe(onNext:{ [weak self] value in
                //设置rank百分比进度条
                print(value)
                self?.reportView.earningProgressBar.setProgress(pro: value)
                let country = self?.contractModel?.Country ?? ""
                self?.reportView.earningProgressTip.text = "Better than \(value)% models in \(country)"
            })
                
        _ = viewModel.jobList.bind(to: self.tableView.rx.items){ (tableView,row,model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MolletReportCell") as! MolletReportCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.name.text = model.Name ?? ""
            cell.date.text = model.Date ?? ""
            cell.duration.text = "\(model.Hours ?? "0") hours"
            var price = "0"
            let percentage = self.contractModel?.Percentage ?? 0
            if let hours = model.Hours,let hourlyPay = model.HourlyPay {
                let value = Float(hours)! * Float(hourlyPay)! * Float(percentage) / Float(100)
                price = "\(self.unit ?? "$")\(String(describing: value))"
            }
            cell.payment.text = price
            cell.editButton.rx.tap.subscribe(onNext:{ _ in
                let jobEditeVC = MolletJobAddViewController()
                jobEditeVC.isJobEdit = true
                jobEditeVC.jobModel = model
                self.navigationController?.pushViewController(jobEditeVC, animated: true)
            }).disposed(by: cell.disposeBag)
            return cell
        }
        
        //查看排名
        _ = reportView.lookButton.rx.tap.subscribe(onNext:{
            let rankVC = MolletRankViewController()
            rankVC.rateArray = self.viewModel.rateArray.value
            self.navigationController?.pushViewController(rankVC, animated: true)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
