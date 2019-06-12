//
//  ClientProtocol.swift
//  Offenbach
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public typealias Headers = [String: String]?
public typealias Parameters = [String: Any]

public typealias DataRequest = AnyObject

public protocol ClientProtocol {
    func set(config: ConfigProtocol) -> ClientProtocol
    func set(token: TokenProtocol?) -> ClientProtocol
}
