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
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        AlamoSession.shared.request(path: "/Login/version") { code, msg in
            print(code == .SUCCESS ? "success" : msg)
        }
    }
    
}

