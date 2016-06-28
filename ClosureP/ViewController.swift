//
//  ViewController.swift
//  ClosureP
//
//  Created by andy on 16/6/28.
//  Copyright © 2016年 foxhis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let waringModeService = WaringModeService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // closure 飞去吧
        waringModeService.changeWaringMode(true) { modeCurrentData, error in
            dispatch_async(dispatch_get_main_queue(), {
                // do anything you want do
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

