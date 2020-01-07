//
//  PreviousOrderHeaderView.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 24/12/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit

class PreviousOrderHeaderView: UIView {

    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var posNumberLabel: UILabel!
    @IBOutlet weak var orderedTime: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        // TODO: Setup view
        containerView.backgroundColor = UIColor.systemGray2
    }
    
    func set(order: OrderResponse) {
        tableNumberLabel.text = order.location?.name ?? "-"
        orderNumberLabel.text = "\(order.name) \(order.isVoided ? " (Void)" : "")"
        posNumberLabel.text = order.location?.zone ?? "-"
        orderedTime.text = order.orderDateTimeString
    }

}
