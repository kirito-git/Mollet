//
//  MolletRankViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletRankViewController: MolletBaseViewController {

    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var headImagevi: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var countryRank: UILabel!
    @IBOutlet weak var countryTip: UILabel!
    @IBOutlet weak var cityRank: UILabel!
    @IBOutlet weak var cityTip: UILabel!
    @IBOutlet weak var cityContainer: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    var viewModel = MolletRankViewModel()
    var rateArray:[MolletRateModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle = "Ranking"
        setupSubViews()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.setRankValue(array: self.rateArray!)
        
        //头像设置
        if let profileUrl = UserDefaults.standard.value(forKey: "ProfilePicUrl") as? String {
            self.headImagevi.sd_setImage(with: URL(string: profileUrl), placeholderImage: UIImage.init(named: "head-placeholder"))
        }
        
        let country = self.viewModel.country.value
        let city  = self.viewModel.city.value
        
        _ = viewModel.name.asObservable().bind(to: self.nameLab.rx.text)
        _ = viewModel.countryRate.asObservable().map{"\($0)%"}.bind(to: self.countryRank.rx.text)
        _ = viewModel.cityRate.asObservable().map{"\($0)%"}.bind(to: self.cityRank.rx.text)
        _ = viewModel.countryTop.asObservable().map{"Top \($0)% within \(country)."}.bind(to: self.countryTip.rx.text)
        _ = viewModel.cityTop.asObservable().map{"Top \($0)% within \(city)."}.bind(to: self.cityTip.rx.text)

        _ = viewModel.isExistCity.asObservable().map{!$0}.bind(to: self.cityContainer.rx.isHidden)
        
        _ = viewModel.isExistCity.asObservable()
            .subscribe(onNext:{ [weak self] exist in
                if exist == false {
                    self?.container.snp.makeConstraints({ (make) in
                        make.height.equalTo(430-70-50)
                    })
                }
            })
    }
    
    func setupSubViews() {
        self.headImagevi.layer.cornerRadius = 40
        self.headImagevi.layer.masksToBounds = true
        
        //没有阴影
        self.shadowView.layer.cornerRadius = 40
//        self.shadowView.layer.shadowColor = UIColor.black.cgColor
//        self.shadowView.layer.shadowOffset = CGSize(width:0,height:5)
//        self.shadowView.layer.shadowOpacity = 0.4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
