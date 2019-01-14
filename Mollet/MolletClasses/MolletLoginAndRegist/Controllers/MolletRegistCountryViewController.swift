//
//  MolletRegistCountryViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletRegistCountryViewController: UIViewController ,CountryAndCityViewDelegate{

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var countryLab: UILabel!
    var countrySelectView:CountryAndCityView!
    
    var viewModel:MolletRegistViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func setupSubviews() {
        countrySelectView = CountryAndCityView.init(frame: CGRect.zero)
        countrySelectView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(countrySelectView)
    }
    
    func bindViewModel() {
        
        _ = viewModel.country.asObservable().bind(to: self.countryLab.rx.text)
        
        //点击选择国家
        _ = self.countryButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.countrySelectView.showCountryOrCityView(isCity:false,country: "")
        })
        
        _ = self.backButton.rx.tap.subscribe(onNext:{
            self.navigationController?.popViewController(animated: true)
        })
        
        _ = self.nextButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .withLatestFrom(self.viewModel.countryVaild)
            .filter({ vaild in
                if vaild == false {
                    print("请选择国家")
                    self.noticeOnlyText("Please select a country!")
                }
                return vaild
            })
            .subscribe(onNext:{ _ in
                let bodyVC = MolletRegistBodyViewController()
                bodyVC.viewModel = self.viewModel
                self.navigationController?.pushViewController(bodyVC, animated: true)
            })
    }

    //代理
    func CountryAndCityViewSelect(indexStr: String, dic: [String : Any], isCity: Bool) {
        print(indexStr)
        if isCity == false {
            self.viewModel.country.value = indexStr
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
