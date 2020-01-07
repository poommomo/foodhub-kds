//
//  MenuResponse.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 26/11/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import ObjectMapper

public class MenuResponse: Mappable {
    
    public var id: Int = 0
    public var name: String = ""
    public var quantity: Int = 0
    public var orderStatus: OrderResponse? = nil
    
    public var isFinished: Bool = false
    
    init() { }
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        quantity <- map["quantity"]
        orderStatus <- map["orderStatus"]
        if let status = orderStatus {
            if status.id == 2 {
                isFinished = true
            }
        }
    }
    
}
