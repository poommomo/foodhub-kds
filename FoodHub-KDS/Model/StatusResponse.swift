//
//  StatusResponse.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 23/12/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import ObjectMapper

public class StatusResponse: Mappable {
    
    public var id: Int = 0
    public var name: String = ""
    
    init() { }
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
}
