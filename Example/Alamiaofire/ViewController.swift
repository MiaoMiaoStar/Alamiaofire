//
//  ViewController.swift
//  Alamiaofire
//
//  Created by 387970107@qq.com on 03/31/2023.
//  Copyright (c) 2023 387970107@qq.com. All rights reserved.
//

import UIKit
import Alamiaofire


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        AlamoSession.shared.config.reqEncrypt = .some(["/Login/loginSms", "/Login/login"])
        
        let params = [
            "apns_token": "28A1BCFF5A2B99F98BD5E49B2A8E2323C866A9A861C677B09F718EDF61BEE3BF",
            "agent": "iPhone13,4-15.4.1",
            "channel": "iOS",
            "code": "666666",
            "device_id": "89C9EDD2-35EB-4CB2-A700-BA328A463804",
            "device_param": "{\"idfa\":\"E9647C47-F76B-4FE9-BE12-7AF370CCD7FA\"}",
            "phone": "16675586666",
            "platformDevice": "ios",
            "version": "1.8.1"
        ]
        AlamoSession.shared.config.parameters = params
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        AlamoSession.shared.request(path: "/Login/version") { code, msg in
//            print(code == .SUCCESS ? "success" : msg)
//        }
        
//        AlamoSession.shared.request(path: "/Login/loginSms", params: ["phone" : "16675589669"]) { code, msg in
//            print(code == .SUCCESS ? "success" : msg)
//        }
        
        AlamoSession.shared.request(path: "/Login/login") { code, msg in
            print(code == .SUCCESS ? "success" : msg)
        }
    }
    
}

