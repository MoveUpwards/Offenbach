//
//  Config.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Alamofire
import Foundation

open class Config: ConfigProtocol {
    open var headers: [HTTPHeader]? {
        [
            .accept("application/json"),
            .contentType("application/json")
        ]
    }
    
    open var baseURL: String {
        "http://localhost:8080"
    }
    
    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public let env: ApiEnvironment

    public required init(env: ApiEnvironment) {
        self.env = env
    }
}
