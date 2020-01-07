//
//  ViewController.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 23/11/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import ObjectMapper

class HomeViewController: UIViewController {
    
    @IBOutlet weak var displayTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var orders: [OrderResponse] = []
    var ref: DatabaseReference!
    
    weak var timer: Timer?
    var timeInterval = 1
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let height = UIScreen.main.bounds.size.height * 0.85
        layout.estimatedItemSize = CGSize(width: 270, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "OrderCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ordercell")
        
//        ref = Database.database().reference()
        
//        ref.child("orders").observeSingleEvent(of: .value) { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//
//            let id = value?["Id"] as? Int ?? 0
//            print(id)
//        }
        setupTimer()
        loadData()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressTapped(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    @IBAction func refreshTapped(_ sender: UIButton) {
        loadData()
    }
    
    
    @objc func loadData() {
        let url = URL(string: "\(AppSetup.endpoint)/display/getorder")!
        var ordersUrl = URLRequest(url: url)
        ordersUrl.httpMethod = "GET"
        
        Alamofire.request(ordersUrl).responseJSON { (response) in
            switch response.response?.statusCode {
            case 200:
                if let value = response.result.value {
                    if let arrayResponse = Mapper<OrderResponse>().mapArray(JSONString: JSON(value).rawString() ?? "") {
                        self.collectionView.subviews.filter({ $0.tag == 9 }).forEach({ $0.removeFromSuperview() })
                        self.orders = arrayResponse
//                        self.orders.append(contentsOf: arrayResponse)
//                        self.orders.append(contentsOf: arrayResponse)
//                        self.orders.append(contentsOf: arrayResponse)
                        self.collectionView.reloadData()
                    }
                }
            case 404:
                let label = UILabel(frame: CGRect(x: self.collectionView.bounds.width / 2, y: 30, width: 100, height: 50))
                label.textAlignment = .center
                label.text = "No Orders"
                label.tag = 9
                self.collectionView.addSubview(label)
            default:
                let alert = UIAlertController(title: "An Error Occurred", message: "(Please try again (\(response.response?.statusCode ?? -1))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ordercell", for: indexPath) as? OrderCell {
            cell.set(order: orders[indexPath.row])
            cell.menuTapped = { menu, orderId in
                self.updateMenuStatus(orderId: orderId, menuId: menu.id, isFinished: menu.isFinished) { (isPassed) in
                    if !isPassed {
                        print("Error update menu status")
                    }
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        updateOrderStatus(orderId: order.id, isFinished: true) { (isPassed) in
            if isPassed {
                self.orders.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
            }
        }
    }
    
    @IBAction func historyTapped(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(identifier: "previousorders") as? PreviousOrdersViewController {
            vc.modalPresentationStyle = .formSheet
            vc.modalTransitionStyle = .coverVertical
            vc.homeVC = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func updateOrderStatus(orderId: Int, isFinished: Bool, isVoided: Bool = false, completion: @escaping (_ updateOrderStatusPassed: Bool) -> Void) {
        var isSuccess = false
        let url = URL(string: "\(AppSetup.endpoint)/display/UpdateOrderStatus?orderId=\(orderId)&isFinished=\(isFinished)&isVoided=\(isVoided)")!
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
    
    @objc private func longPressTapped(gesture: UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let position = gesture.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: position) {
            let order = orders[indexPath.row]
            let alert = UIAlertController(title: "Order Option", message: "Select action for order \(orders[indexPath.row].name)", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Void Order", style: .destructive, handler: { (_) in
                self.updateOrderStatus(orderId: order.id, isFinished: order.isFinished, isVoided: true) { (isPassed) in
                    if isPassed {
                        self.orders.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                    } else {
                        print("Error change void status")
                    }
                }
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = collectionView
                popoverController.sourceRect = CGRect(x: position.x, y: position.y, width: 0, height: 0)
            }
            present(alert, animated: true, completion: nil)
            
        } else {
            print("can't find indexpath after long press")
        }
    }
    
    private func updateMenuStatus(orderId: Int, menuId: Int, isFinished: Bool, completion: @escaping (_ requestUpdateStatusPassed: Bool) -> Void) {
        var isSuccess = false
        var status = 1
        if isFinished {
            status = 2
        }
        let url = URL(string: "\(AppSetup.endpoint)/display/UpdateMenuStatus?orderId=\(orderId)&menuId=\(menuId)&statusId=\(status)")!
        var updateStatusUrl = URLRequest(url: url)
        updateStatusUrl.httpMethod = "GET"
        
        Alamofire.request(updateStatusUrl).response { (response) in
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

