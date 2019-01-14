//
//  MolletBalanceCell.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/17.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletBalanceCell: UITableViewCell {

    @IBOutlet weak var unitLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var inputTf: UITextField!
    @IBOutlet weak var dateType: UILabel!
    @IBOutlet weak var dateTypeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view1.layer.cornerRadius = 4
        view2.layer.cornerRadius = 4
    }
    
    //单元格重用时调用
    //每次 prepareForReuse() 方法执行时都会初始化一个新的 disposeBag。这是因为 cell 是可以复用的，这样当 cell 每次重用的时候，便会自动释放之前的 disposeBag，从而保证 cell 被重用的时候不会被多次订阅，避免错误发生。
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
