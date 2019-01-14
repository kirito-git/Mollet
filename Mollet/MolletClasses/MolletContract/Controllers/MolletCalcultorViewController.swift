//
//  MolletCalcultorViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/18.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletCalcultorViewController: MolletBaseViewController {

    
    @IBOutlet weak var container: UIView!
    //放置ruler的view
    @IBOutlet weak var rulerContent: UIView!
    @IBOutlet weak var rulerValueLab: UILabel!
    @IBOutlet weak var addJobButton: UIButton!
    @IBOutlet weak var jobListButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var incomeLab: UILabel!
    @IBOutlet weak var expenseLab: UILabel!    
    @IBOutlet weak var countDownTf: UITextField!
    
    var ruler:RulerView!
    var viewModel:MolletCalcultorViewModel!
    var unit:String?
    
    var contractModel:MolletContractModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle = "Calculator"
        setupSubviews()
        bindViewModel()
    }
    
    func setupSubviews() {
        ruler = RulerView.init(frame: MRect(x: 0, y: 0, width: rulerContent.frame.size.width, height: 100))
        self.rulerContent.addSubview(ruler)
        self.rulerValueLab.adjustsFontSizeToFitWidth = true
        
        //垂直居中
        self.countDownTf.contentVerticalAlignment = .center
        //self.countDownTf.minimumFontSize = 14.0
        self.countDownTf.adjustsFontSizeToFitWidth = true
        
        if SCREEN_WIDTH == 320.0 {
            container.snp.makeConstraints({ (make) in
                make.height.equalTo(ScaleWidth(value: SCREEN_WIDTH))
            })
        }
    }

    func bindViewModel() {
        viewModel = MolletCalcultorViewModel()
        viewModel.setContractModel(model: self.contractModel!)
        //合同收支详情
        MBProgressHUDSwift.showLoading()
        _ = viewModel.contractDetailRequest()
        
        //货币单位
        let country = self.contractModel?.Country ?? ""
        unit = MolletTools.unitFromCountry(country: country)
        
        _ = viewModel.income.asObservable().map{"\(String(describing: Int(round(Double($0)!))))\(self.unit!)"}.bind(to: self.incomeLab.rx.text)
        _ = viewModel.wallet.asObservable()
            .subscribe(onNext: { Str in
                let walletValue = String(describing: Int(round(Double(Str)!)))
                print(walletValue)
                self.rulerValueLab.text = "\(walletValue)\(self.unit!)"
                self.ruler.setPerValueWithOriginValue(value: Str)
                self.ruler.setRulerValue(value: CGFloat(Float(Str) ?? 0.0))
            })
        _ = viewModel.expense.asObservable().map{"\(String(describing: Int(round(Double($0)!))))\(self.unit!)"}.bind(to: self.expenseLab.rx.text)
        _ = viewModel.countDown.asObservable().bind(to: self.countDownTf.rx.text)
        
        //使用KVO监听尺子滑动的resultValue
        //刻度保持为整数
        //_ = ruler.rx.observe(String.self, "resultValue").bind(to: self.rulerValueLab.rx.text)
        _ = ruler.rx.observe(UIColor.self, "currentColor").subscribe(onNext:{
            [weak self] color in
            self?.rulerValueLab.textColor = color
        })
        //添加工作
        _ = self.addJobButton.rx.tap.subscribe(onNext:{[weak self] in
            let addJobVC = MolletJobAddViewController()
            addJobVC.isJobEdit = false
            addJobVC.contractModel = self?.contractModel
            self?.navigationController?.pushViewController(addJobVC, animated: true)
        })
        //工作列表
        _ = self.jobListButton.rx.tap.subscribe(onNext:{[weak self] in
            let jobVC = MolletJobListViewController()
            jobVC.contractModel = self?.contractModel
            self?.navigationController?.pushViewController(jobVC, animated: true)
        })
        //report
        _ = self.reportButton.rx.tap.subscribe(onNext:{[weak self] in
            let reportVC = MolletReportViewController()
            reportVC.calcultorVM = self?.viewModel
            reportVC.contractModel = self?.contractModel
            reportVC.unit = self?.unit!
            self?.navigationController?.pushViewController(reportVC, animated: true)
        })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: RefreshCalculatorDataNotification))
            .takeUntil(self.rx.deallocated)//页面销毁自动移除通知监听
            .subscribe(onNext:{ _ in
                //刷新详情
                _ = self.viewModel.contractDetailRequest()
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
