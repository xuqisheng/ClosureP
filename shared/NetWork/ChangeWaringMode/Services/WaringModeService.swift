//
//  WaringModeService.swift
//  HomeGuard
//
//  Created by Andy on 16/6/26.
//  Copyright © 2016年 Andy. All rights reserved.
//

import Foundation


class WaringModeService : WebService {
    let urlPath = "**.php"
    
    private let baseURL = NSURL(string :"**.php")!
    
    init() {
        super.init(rootURL: baseURL)
    }
    
    
    func changeWaringMode(statuToChange: Bool,
                          completion: (modeCurrentData:ModeCurrentData?, error: NSError!) -> Void) {
        
        var mode:String!
        
        if ( statuToChange ) {
            mode = "open"
        } else {
            mode = "close"
        }
        let paramters = ["ChangeWaringMode" : mode]
        
        
        executeDictionaryRequest(urlPath, postData: paramters) { (dictionary, error) in
            guard let dictionary = dictionary else {
                completion(modeCurrentData: nil, error: error)
                return
            }
            completion(modeCurrentData: ModeCurrentData(withJson: dictionary), error: error)
        }
    }
}
