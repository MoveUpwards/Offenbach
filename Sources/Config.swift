//
//  Config.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

open class Config: ConfigProtocol {
    open var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    open var baseURL: String {
        return "http://localhost:8080"
    }

    public let env: ApiEnvironment
    public let decoder: JSONDecoder

    public required init(env: ApiEnvironment, decoder: JSONDecoder = JSONDecoder()) {
        self.env = env
        self.decoder = decoder
    }
}
