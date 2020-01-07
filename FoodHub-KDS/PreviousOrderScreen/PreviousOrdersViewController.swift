//
//  PreviousOrdersViewController.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 23/12/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

class PreviousOrdersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var homeVC: HomeViewController?
    var orders: [OrderResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let homeVC = homeVC {
            homeVC.loadData()
        }
    }
    
    private func loadData() {
        let url = URL(string: "\(AppSetup.endpoint)/display/GetPreviousOrder")!
        var ordersUrl = URLRequest(url: url)
        ordersUrl.httpMethod = "GET"
        
        Alamofire.request(ordersUrl).responseJSON { (response) in
            switch response.response?.statusCode {
            case 200:
                if let value = response.result.value {
                    if let arrayResponse = Mapper<OrderResponse>().mapArray(JSONString: JSON(value).rawString() ?? "") {
                        self.tableView.subviews.filter({ $0.tag == 9 }).forEach({ $0.removeFromSuperview() })
                        self.orders = arrayResponse
                        self.tableView.reloadData()
                    }
                }
            case 404:
                let label = UILabel(frame: CGRect(x: self.tableView.bounds.width / 2, y: 30, width: 100, height: 50))
                label.textAlignment = .center
                label.text = "No Orders"
                label.tag = 9
                self.tableView.addSubview(label)
            default:
                let alert = UIAlertController(title: "An Error Occurred", message: "(Please try again (\(response.response?.statusCode ?? -1))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateOrderStatus(orderId: Int, isFinished: Bool, completion: @escaping (_ updateOrderStatusPassed: Bool) -> Void) {
        var isSuccess = false
        let url = URL(string: "\(AppSetup.endpoint)/display/UpdateOrderStatus?orderId=\(orderId)&isFinished=\(isFinished)")!
        var updateOrderUrl = URLRequest(url: url)
        updateOrderUrl.httpMethod = "GET"
        
        Alamofire.request(updateOrderUrl).response { (response) in
            switch response.response?.statusCode {
            case 200:
                isSuccess = true
            default:
                isSuccess = false
            }
            completion(isSuccess)
        }
    }
    
}

extension PreviousOrdersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders[section].menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "detailcell") {
            let menu = orders[indexPath.section].menus[indexPath.row]
            cell.textLabel?.text = menu.name
            cell.detailTextLabel?.text = "Qty: \(menu.quantity)"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.section]
        if !order.isVoided {
            let alert = UIAlertController(title: "Restore Order", message: "Are you sure you want to restore order \(order.name)", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                self.updateOrderStatus(orderId: order.id, isFinished: false) { (isPassed) in
                    if isPassed {
                        self.orders.remove(at: indexPath.section)
                        self.tableView.reloadData()
                    } else {
                        print("Error change status")
                    }
                }
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = tableView
                let frame = tableView.rectForRow(at: indexPath)
                popoverController.sourceRect = frame
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("PreviousOrderHeaderView", owner: self, options: nil)?.first as! PreviousOrderHeaderView
        headerView.set(order: orders[section])
        return headerView
    }
    
}
