//
//  MenuCell.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 26/11/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var finishedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(menu: String, quantity: Int, isFinished: Bool) {
        finishedView.isHidden = !isFinished
        menuLabel.text = menu
        quantityLabel.text = "x \(quantity)"
    }
    
}
