//
//  MolletJobAddViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletJobAddViewController: MolletBaseViewController ,DropDownDelegate, DateViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var typeLab: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var bookerTf: UITextField!
    @IBOutlet weak var jobHoursTf: UITextField!
    @IBOutlet weak var paymentTf: UITextField!
    @IBOutlet weak var totalPayTf: UITextField!
    
    @IBOutlet weak var jobHoursTips: UILabel!
    @IBOutlet weak var payPerHourTips: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    
    var dropview:DropDownView!
    var dateView:DateView!
    
    var unit = "$"
    
    //传递的数据
    var isJobEdit:Bool?
    var jobModel:MolletJobModel?
    var contractModel:MolletContractModel?
    
    var viewModel:MolletJobAddViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }

    func setupSubviews() {
        for view in contentView.subviews {
            if view.tag > 10 {
                view.layer.cornerRadius = 4
            }
        }
        self.navTitle = isJobEdit! == true ? "Edit Job" : "Add Job"
        let country = self.contractModel?.Country ?? ""
        unit = MolletTools.unitFromCountry(country: country)
        self.paymentTf.placeholder = unit
    }
    
    func bindViewModel() {
        viewModel = MolletJobAddViewModel()
        if let cModel = self.contractModel {
            self.viewModel.contractId.value = cModel.ContractId?.description ?? ""
        }
        
        _ = self.nameTf.rx.textInput <-> viewModel.name
        _ = viewModel.type.asObservable().bind(to: self.typeLab.rx.text)
        _ = viewModel.date.asObservable().bind(to: self.dateButton.rx.title(for: .normal))
        _ = self.bookerTf.rx.textInput <-> viewModel.booker
        _ = self.jobHoursTf.rx.textInput <-> viewModel.jobHours
        _ = self.paymentTf.rx.textInput <-> viewModel.payment
        _ = self.jobHoursTf.rx.text.orEmpty.asObservable()
            .filter({ text in
                let vaild = MolletTools.isFloat(string: self.jobHoursTf.text!)
                if vaild == false {
                    self.noticeOnlyText("Please use the correct sign - \".\"")
                }
                return vaild
            }).subscribe(onNext:{_ in
                
            })
        
        _ = Observable.combineLatest(viewModel.jobHours.asObservable(),viewModel.payment.asObservable()){(value1,value2) -> Float in
            return (Float(value1) ?? Float(0)) * (Float(value2) ?? Float(0))
        }
        .map{"\(self.unit)\($0.description)"}
        .bind(to: self.totalPayTf.rx.text)

        
        if self.isJobEdit! == true {
            //如果是编辑
            self.viewModel.name.value = self.jobModel?.Name ?? ""
            self.viewModel.type.value = self.jobModel?.JType ?? ""
            self.viewModel.date.value = self.jobModel?.Date ?? ""
            self.viewModel.booker.value = self.jobModel?.Booker ?? ""
            self.viewModel.jobHours.value = self.jobModel?.Hours ?? ""
            self.viewModel.payment.value = self.jobModel?.HourlyPay ?? ""
            let totalPay = Float(self.jobModel?.Hours ?? "0")! * Float(self.jobModel?.HourlyPay ?? "0")!
            print(String(describing: totalPay))
            self.viewModel.totalPay.value = String(describing: totalPay)
        }
        
        //类型选择
        _ = self.typeButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.view.endEditing(true)
            self?.choseType()
        })
        //时间选择
        _ = self.dateButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.view.endEditing(true)
            self?.choseDate()
        })
        //取消键盘响应
        let cancelEditTap = UITapGestureRecognizer()
        self.contentView.addGestureRecognizer(cancelEditTap)
        _ = cancelEditTap.rx.event.subscribe(onNext:{[weak self] recognizer in
            self?.view.endEditing(true)
        })
        
        //添加点击
        let okSelectVaild = okButton.rx.tap
            .throttle(0.6, scheduler: MainScheduler.instance)
            .loadingPlugin()
            .withLatestFrom(self.viewModel.inputVaild)
            .filter({ vaild in
                if vaild == false {
                    self.noticeOnlyText("Please fill in the full and correct information!")
                }
                return vaild
            })
            
        if self.isJobEdit == true {
            //编辑
            let jobid = String(describing: self.jobModel?.JobId ?? 0)
            
            _ = okSelectVaild
            .flatMapLatest{_ in
                self.viewModel.updateContractJobRequest(jobId: jobid)
            }
            .subscribe(onNext:{ response in
                self.noticeOnlyText("Update completed!")
                self.navigationController?.popViewController(animated: true)
                //刷新合同详情
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshCalculatorDataNotification), object: nil)
            })
            
        }else {
            //增加
            _ = okSelectVaild
                .flatMapLatest{_ in
                    self.viewModel.addContractJobRequest()
                }
                .subscribe(onNext:{ response in
                    self.noticeOnlyText("Created successfully!")
                    //刷新合同详情
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: RefreshCalculatorDataNotification), object: nil)
                    self.navigationController?.popViewController(animated: true)
                })
        }
    }
    
    //选择类型
    func choseType() {
        let startY = 90 - scrollView.contentOffset.y
        let startPoint = CGPoint(x:SCREEN_WIDTH-110,y:startY)
        //展示下拉选项
        if dropview == nil {
            dropview = DropDownView()
        }
        dropview.delegate = self
        view.addSubview(dropview)
        dropview.showDropDown(titles: viewModel.dropList.value, point: startPoint)
    }
    
    // DropViewDelegate
    func cellSelect(index: Int) {
        let typeArray = viewModel.dropList.value
        let choseType = typeArray[index]
        viewModel.type.value = choseType
        //更新view布局
        if choseType == "Event" || choseType == "Show" {
            self.jobHoursTips.text = "Job Days"
            self.payPerHourTips.text = "Payment Per Day"
            self.jobHoursTf.placeholder = "days"
            jobHoursTf.keyboardType = UIKeyboardType.numberPad
        }else {
            self.jobHoursTips.text = "Job Hours"
            self.payPerHourTips.text = "Payment Per Hour"
            self.jobHoursTf.placeholder = "hours"
            jobHoursTf.keyboardType = UIKeyboardType.decimalPad
        }
    }
    
    //选择时间
    func choseDate() {
        //添加dateview
        if dateView == nil {
            dateView = DateView()
        }
        dateView.delegate = self
        self.view.addSubview(dateView)
        dateView.showDatePicker(showTime: false)
    }
    
    // DateViewDelegate
    func selectDateString(dateString: String, timestamp: Double) {
        viewModel.date.value = dateString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}


//extension MolletJobAddViewController: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        let str = self.viewModel.stringTransform(originStr: textField.text!)
//        textField.text = str
//    }
//}

