//
//  MolletReportHeader.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/9/19.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit

class MolletReportHeader: UIView {

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var earningLabel: UILabel!
    @IBOutlet weak var earningValueLabel: UILabel!
    @IBOutlet weak var earningProgressView: UIView!
    @IBOutlet weak var earningTipLabel: UILabel!
    @IBOutlet weak var leftDaysLabel: UILabel!
    
    class func instanceReportHeader () ->  MolletReportHeader {
        let nib = UINib.init(nibName: "MolletReportHeader", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0]
        return view as! MolletReportHeader
    }
}
