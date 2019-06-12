//
//  Config.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

open class Config: ConfigProtocol {
    public static var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    public let baseURL: String
    public let decoder: JSONDecoder

    required public init(baseURL: String, decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.decoder = decoder
    }
}
