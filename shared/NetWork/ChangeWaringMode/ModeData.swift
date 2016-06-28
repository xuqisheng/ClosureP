//
//  ModeData.swift
//  HomeGuard
//
//  Created by Andy on 16/6/26.
//  Copyright © 2016年 Andy. All rights reserved.
//

import Foundation


struct ModeCurrentData {
    let mode: String?
    let requestSuccess : String?
    var message: String?
    
    init?(withJson json:NSDictionary) {
        guard let success = json["success"] as? String,
        let modeStr = json["waringmode"] as? String
        else {
            return nil
        }
        
        self.message  = ""
        if let mess =  json["message"]{
            self.message = mess as? String
        }
        
        self.requestSuccess = success
        self.mode = modeStr
        
    }
    
}