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
    open var headers: [HTTPHeader] { [.accept("application/json")] }

    open var baseURL: String { "http://localhost:8080" }

    public let env: ApiEnvironment
    
    public let decoder: DataDecoder

    public required init(env: ApiEnvironment, decoder: DataDecoder = JSONDecoder()) {
        self.env = env
        self.decoder = decoder
    }
}
