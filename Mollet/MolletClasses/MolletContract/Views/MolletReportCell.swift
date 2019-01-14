//
//  MolletReportCell.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import RxSwift

class MolletReportCell: UITableViewCell {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    //单元格重用时调用
    //每次 prepareForReuse() 方法执行时都会初始化一个新的 disposeBag。这是因为 cell 是可以复用的，这样当 cell 每次重用的时候，便会自动释放之前的 disposeBag，从而保证 cell 被重用的时候不会被多次订阅，避免错误发生。
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
