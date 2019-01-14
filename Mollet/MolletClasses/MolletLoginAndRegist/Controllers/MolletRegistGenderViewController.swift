//
//  MolletRegistGenderViewController.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/20.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletRegistGenderViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var boyButton: UIButton!
    @IBOutlet weak var grilButton: UIButton!
    
    var viewModel:MolletRegistViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindViewModel()
    }
    
    func bindViewModel() {
        self.viewModel.genderButtons.accept([self.boyButton,self.grilButton])
        self.viewModel.setButtonSelectViewModel()
        
        _ = self.backButton.rx.tap.subscribe(onNext:{
            self.navigationController?.popViewController(animated: true)
        })
        _ = self.nextButton.rx.tap.subscribe(onNext:{
            let countryVC = MolletRegistCountryViewController()
            countryVC.viewModel = self.viewModel
            self.navigationController?.pushViewController(countryVC, animated: true)
        })
    }
    
    func setupSubviews() {
        self.boyButton.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
        self.boyButton.setBackgroundImage(UIImage.init(named: "gender_select"), for: .selected)
        self.grilButton.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
        self.grilButton.setBackgroundImage(UIImage.init(named: "gender_select"), for: .selected)
        //默认boy选中
        self.boyButton.isSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
