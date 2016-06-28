//
//  StringTool.swift
//  HomeGuard
//
//  Created by Andy on 16/6/26.
//  Copyright © 2016年 Andy. All rights reserved.
//

import Foundation


extension String {

    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}