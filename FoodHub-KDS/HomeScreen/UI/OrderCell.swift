//
//  OrderCell.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 26/11/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit

protocol OrderCellDelegate {
    func menuTapped()
}

class OrderCell: UICollectionViewCell {
    
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var posNumberLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: OrderCellDelegate?
    var menus: [MenuResponse] = []
    
    var menuTapped: ((_ result: MenuResponse, _ orderId: Int) -> ())?
    
    weak var timer: Timer?
    var timeTaken: Int = 0
    var orderId: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MenuCell", bundle: Bundle.main), forCellReuseIdentifier: "menucell")
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func prepareForReuse() {
        timer?.invalidate()
    }
    
    @objc func updateTimer() {
        timeTaken += 1
        let timeElapsed = timeTaken.secondsToHoursMinutesSeconds()
        timeElapsedLabel.text = "\(timeElapsed.1):\(timeElapsed.2)"
        
        if timeTaken <= 10 {
            orderStatusView.backgroundColor = UIColor.systemGreen
        } else if timeTaken > 10 && timeTaken < 20 {
            orderStatusView.backgroundColor = UIColor.systemOrange
        } else {
            orderStatusView.backgroundColor = UIColor.systemRed
        }
    }
    
    func set(order: OrderResponse) {
        self.orderId = order.id
        
        orderStatusView.backgroundColor = order.orderStatusColor
        tableNumberLabel.text = order.location?.name ?? "-"
        orderNumberLabel.text = order.name
//        if let elapsedTime = order.orderDateTime.getTimeDifference(), let min = elapsedTime.minute, let sec = elapsedTime.second {
//            timeElapsedLabel.text = "\(min):\(sec)"
//        }
        if let elasedTime = order.orderDateTime.getTimeDifference() {
            timeElapsedLabel.text = elasedTime.dateComponentToString()
        }
        self.menus = order.menus
        
//        runTimer()
        tableView.reloadData()
    }

}

extension OrderCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menucell") as? MenuCell {
            
            cell.set(menu: menus[indexPath.row].name, quantity: menus[indexPath.row].quantity, isFinished: menus[indexPath.row].isFinished)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menus[indexPath.row].isFinished = !menus[indexPath.row].isFinished
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        menuTapped?(menus[indexPath.row], orderId)
    }
    
}
