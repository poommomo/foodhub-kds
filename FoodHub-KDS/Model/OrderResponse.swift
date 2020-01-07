//
//  OrderResponse.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 26/11/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import ObjectMapper

public class OrderResponse: Mappable {
    
    public var id: Int = 0
    public var name: String = ""
    public var orderDateTime: String = ""
    public var isFinished: Bool = false
    public var isVoided: Bool = false
    public var location: LocationResponse? = nil
    public var menus: [MenuResponse] = []
    
    public var orderDateTimeString: String {
        get {
            return orderDateTime.dateFromStringUTC()
        }
    }
    public var orderStatusColor: UIColor {
        get {
            return orderDateTime.getTimeDifferenceColor()
        }
    }
    
    public init() { }
    
    public init(name: String, menus: [MenuResponse]) {
        self.name = name
        self.menus = menus
    }
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        orderDateTime <- map["orderDateTime"]
        isFinished <- map["isFinished"]
        isVoided <- map["isVoided"]
        location <- map["location"]
        menus <- map["menus"]
    }
    
}

