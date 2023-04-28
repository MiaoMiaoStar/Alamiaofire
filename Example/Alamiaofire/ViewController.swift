//
//  ViewController.swift
//  Alamiaofire
//
//  Created by 387970107@qq.com on 03/31/2023.
//  Copyright (c) 2023 387970107@qq.com. All rights reserved.
//

import UIKit
import Alamiaofire
import HandyJSON

public struct User: HandyJSON {
    
    public var nickname: String!
    public var face: String!
    public var is_new: Int?
    public var user_number: Int!
    public var pretty_user_number: Int!
    public var token: String?
    public var user_id: Int!
    public var has_verify: Int!
    public var im_user_sig: String?
    
    public init() { }
    
    mutating public func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.user_id <-- "id"
    }
}

public struct MUser: Codable, Hashable {
    
    public let nickname: String
    public let face: String
    public let is_new: Int?
    public let user_number: Int
    public let pretty_user_number: Int
    public let token: String?
    public let user_id: Int
    public let has_verify: Int
    public let im_user_sig: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case nickname
        case face
        case is_new
        case user_number
        case pretty_user_number
        case token
        case user_id = "id"
        case has_verify
        case im_user_sig
    }
}

struct Cat: HandyJSON {
    var id: Int64!
    var name: String!
}


public struct AppConfig: Codable {
    public var all_member_push: String? //获取全员推送群ID（传了该参数则会返回配置信息）
    public var rtc_type: String? //tencent=腾讯；agora=声网
    public var sup_msg_tip: String? //房管提示语
    public var sup_msg_warning: String? //房管警告语
    public var sup_msg_punish: String? // 房管处罚语
    public var show_pretty_mall: Int //是否关闭商城显示 = 1 打开 = 0 关闭
    public var black_white_theme: Bool //是否置灰
    
    public var isShowPrettySmall: Bool { show_pretty_mall == 1}
    
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        AlamoSession.shared.config.reqEncrypt = .some(["/Login/loginSms", "/Login/login"])
        
        let params = [
            "rtc_type": 1,
            "agent": "iPhone13,4-15.4.1",
            "device_id": "F5E3FEEB-C865-4760-B04F-926E74F3982E",
            "platformDevice": "ios",
            "all_member_push": 1,
            "channel": "iOS",
            "package_name": "net.huidapay.live",
            "version": "1.9.1",
            "token": "69255995372afd657a9ddabef0ed932c"
        ] as [String: Any]
        AlamoSession.shared.config.parameters = params
        
//        let jsonString = "{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}"
//
//        if let cat = JSONDeserializer<Cat>.deserializeFrom(json:jsonString, designatedPath: "data.cat") {
//            let name = cat.name
//            print("name is \(name)")
//        }
        
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
        
//        AlamoSession.shared.request(path: "/Login/login") { code, msg in
//            print(code == .SUCCESS ? "success" : msg)
//        }
        
//        AlamoSession.shared.request(path: "/Login/login") { (usr: MUser) in
//            print("name = \(usr.nickname), id = \(usr.user_id)")
//        } onFailure: { code, msg in
//            print(msg)
//        }
        
        AlamoSession.shared.request(path: "/app/config", onSuccess: { (config: AppConfig) in
            print(config)
        }) { code, msg in
            print(msg)
        }

        
//
//        AlamoService.shared.request(path: "/Login/login") { (usr: User) in
//            let nickName = usr.nickname
//
//            print("name = \(usr.nickname), id = \(usr.user_id)")
//        } onFailure: { code, msg in
//            print(msg)
//        }

        
    }
    
}

