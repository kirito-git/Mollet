//
//  MolletContractDetailViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/14.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletContractDetailViewController: MolletBaseViewController, CountryAndCityViewDelegate {

    
    @IBOutlet weak var topView1: UIView!
    @IBOutlet weak var topView2: UIView!
    @IBOutlet weak var topView3: UIView!
    @IBOutlet weak var topView4: UIView!
    
    @IBOutlet weak var GuaranteeBtn: UIButton!
    @IBOutlet weak var percentageBtn: UIButton!
    
    @IBOutlet weak var percent1Btn: UIButton!
    @IBOutlet weak var percent2Btn: UIButton!
    @IBOutlet weak var percent3Btn: UIButton!
    
    @IBOutlet weak var taxTf: UITextField!
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var startDateLab: UILabel!
    @IBOutlet weak var endDateLab: UILabel!
    @IBOutlet weak var countryLab: UILabel!
    @IBOutlet weak var cityLab: UILabel!
    
    
    var viewModel:MolletContractDetailViewModel!
    //是否是编辑
    var isContractEdit:Bool?
    var contractModel:MolletContractModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func setupSubviews() {
        self.navTitle = "Contract"
        self.content.snp.makeConstraints { (make) in
            make.height.equalTo(ScaleWidth(value: 460))
        }
        self.nextButton.snp.makeConstraints { (make) in
            make.height.equalTo(ScaleWidth(value: 48))
            make.bottom.equalTo(ScaleWidth(value: -60))
        }
        for view in content.subviews {
            if view.tag > 0 && view.tag < 5 {
                view.layer.cornerRadius = 6
            }else if (view.tag > 10) {
                view.layer.cornerRadius = 3
                view.layer.borderWidth = 1
                view.layer.borderColor = MainBgColor.cgColor
                if view.isKind(of: UIButton.self) {
                    let button = view as! UIButton
                    button.setTitleColor(DetailColor, for: .normal)
                    button.setTitleColor(UIColor.white, for: .selected)
                    button.setBackgroundImage(UIImage.init(named: ""), for: .normal)
                    button.setBackgroundImage(UIImage.init(named: "contract_select"), for: .selected)
                    _ = button.rx.tap.subscribe(onNext: { (sender) in
                        print(sender)
                    })
                }
            }
        }

    }
    
    func bindViewModel() {
        viewModel = MolletContractDetailViewModel()
        //初始化数据
        let Gbutton = self.content.viewWithTag(11) as! UIButton
        Gbutton.isSelected = true//默认选中
        let Pbutton = self.content.viewWithTag(12) as! UIButton
        let percent40 = self.content.viewWithTag(13) as! UIButton
        percent40.isSelected = true//默认选中
        let percent50 = self.content.viewWithTag(14) as! UIButton
        let percent60 = self.content.viewWithTag(15) as! UIButton
        viewModel.typeButtons.accept([Gbutton,Pbutton])
        viewModel.percentButtons.accept([percent40,percent50,percent60])
        viewModel.typeSingleSelect()
        viewModel.percentSingleSelect()
        
        //绑定viewmodel
        let tap1 = UITapGestureRecognizer()
        let tap2 = UITapGestureRecognizer()
        let tap3 = UITapGestureRecognizer()
        let tap4 = UITapGestureRecognizer()
        topView1.addGestureRecognizer(tap1)
        topView2.addGestureRecognizer(tap2)
        topView3.addGestureRecognizer(tap3)
        topView4.addGestureRecognizer(tap4)
        
        if isContractEdit! == true {
            //如果是编辑
            viewModel.startDate.value = contractModel?.StartDate ?? ""
            viewModel.endDate.value = contractModel?.EndDate ?? ""
            viewModel.city.value = contractModel?.City ?? ""
            viewModel.country.value = contractModel?.Country ?? ""
            viewModel.contractType.value = contractModel?.CType ?? ""
            viewModel.percentValue.value = String(describing: contractModel?.Percentage ?? 0)
            if viewModel.contractType.value == "Percentage" {
                Gbutton.isSelected = false
                Pbutton.isSelected = true
            }
            _ = viewModel.percentButtons.value
                .map{ $0.isSelected = false }
            if viewModel.percentValue.value == "40" {
                percent40.isSelected = true
            }else if viewModel.percentValue.value == "50" {
                percent50.isSelected = true
            }else if viewModel.percentValue.value == "60" {
                percent60.isSelected = true
            }
            self.taxTf.text = "\(contractModel?.Tax ?? "0")%"
        }
        
        _ = viewModel.startDate.asObservable().bind(to: self.startDateLab.rx.text)
        _ = viewModel.endDate.asObservable().bind(to: self.endDateLab.rx.text)
        _ = viewModel.city.asObservable().bind(to: self.cityLab.rx.text)
        _ = viewModel.country.asObservable().bind(to: self.countryLab.rx.text)
        
        //开始时间选择
        _ = tap1.rx.event.subscribe(onNext:{[weak self] recognizer in
            let datePickerView = DateView()
            datePickerView.showDatePicker(showTime: false)
            datePickerView.finishBlock = { (dateStr, timeStamp) in
                print(timeStamp)
                self?.viewModel.startDate.value = dateStr ?? ""
            }
        })
        //结束时间选择
        _ = tap2.rx.event.subscribe(onNext:{[weak self] recognizer in
            let datePickerView = DateView()
            datePickerView.showDatePicker(showTime: false)
            datePickerView.finishBlock = { (dateStr, timeStamp) in
                print(timeStamp)
                self?.viewModel.endDate.value = dateStr ?? ""
            }
        })
        //国家选择
        _ = tap3.rx.event.subscribe(onNext:{[weak self] recognizer in
            let countrySelectView = CountryAndCityView()
            countrySelectView.delegate = self
            countrySelectView.showCountryOrCityView(isCity:false,country: "")
        })
        //城市选择
        _ = tap4.rx.event
            .withLatestFrom(self.viewModel.isSelectedChina)
            .filter({ vaild in
                if vaild == false {
                    //此选项只支持China
                    self.noticeOnlyText("Only supported China、USA、Japan、India!")
                }
                return vaild
            })
            .subscribe(onNext:{[weak self] recognizer in
                let countrySelectView = CountryAndCityView()
                countrySelectView.delegate = self
                countrySelectView.showCountryOrCityView(isCity:true, country: (self?.viewModel.country.value)!)
            })
        
        //下一步
        _ = nextButton.rx.tap
            .throttle(0.6, scheduler: MainScheduler.instance)
            //withLatestFrom 当self.viewModel.inputAndCityVaild 发生变化时才响应按钮的事件，（即合并序列后，后者有变化才响应前者）
            .withLatestFrom(self.viewModel.inputAndCityVaild())
            .filter({ vaild in
                if vaild == false {
                    self.noticeOnlyText("Please enter full information!")
                }
                return vaild
            })
            .subscribe(onNext:{ _ in
                let balanceVC = MolletBalanceViewController()
                balanceVC.contractVM = self.viewModel
                balanceVC.isContractEdit = self.isContractEdit
                balanceVC.contractModel = self.contractModel
                self.navigationController?.pushViewController(balanceVC, animated: true)
            })
        
        //注册textfiled文本改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(tfEndEdit), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(beginEditing), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
    }
    
    //国家选择代理
    func CountryAndCityViewSelect(indexStr: String, dic: [String : Any], isCity: Bool) {
        print(indexStr)
        if isCity == true {
            self.viewModel.city.value = indexStr
        }else {
            if indexStr != "China" {
                self.viewModel.city.value = "City"
            }
            self.viewModel.country.value = indexStr
        }
    }
    
    @objc func tfEndEdit(noti:NSNotification) {
        let textfiled = noti.object as! UITextField
        textfiled.text = self.viewModel.appendPercentageSign(text: textfiled.text!)
    }
    
    @objc func beginEditing(noti:NSNotification) {
        let textfiled = noti.object as! UITextField
        let text = textfiled.text!.replacingOccurrences(of: "%", with: "")
        textfiled.text = text
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}




