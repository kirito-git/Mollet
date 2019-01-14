//
//  MolletContractCell.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/14.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletContractCell: UITableViewCell {

    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var contractName: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.backgroundColor = MainBgColor
        //遍历子视图,找出左滑按钮
        print(UIDevice.current.systemVersion)
        //@available(iOS 9.0, *)
        if SYSTEM_VER_GREATER_11_0() {
            return
        }
        var buttonArray = [UIButton]()
        for view in self.subviews {
            if view.isKind(of: NSClassFromString("UITableViewCellDeleteConfirmationView")!) {
                for btn in view.subviews {
                    if btn .isKind(of: UIButton.self) {
                        let actionButton:UIButton = btn as! UIButton
                        buttonArray.append(actionButton)
                    }
                }
            }
        }
        if buttonArray.count == 2 {
            //设置删除按钮
            buttonArray[0].setImage(UIImage.init(named: "cell-delete"), for: UIControlState.normal)
            buttonArray[0].imageEdgeInsets = UIEdgeInsetsMake(28, 0, 0, 0)
            //设置编辑按钮
            buttonArray[1].setImage(UIImage.init(named: "cell-edite"), for: UIControlState.normal)
            buttonArray[1].imageEdgeInsets = UIEdgeInsetsMake(28, 0, 0, 0)
        }
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
