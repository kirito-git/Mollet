//
//  MolletJobListCell.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletJobListCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var duration: UILabel!
    
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
            buttonArray[0].imageEdgeInsets = UIEdgeInsetsMake(0, 0, 27, 0)
            //设置编辑按钮
            buttonArray[1].setImage(UIImage.init(named: "cell-edite"), for: UIControlState.normal)
            buttonArray[1].imageEdgeInsets = UIEdgeInsetsMake(0, 0, 27, 0)
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
