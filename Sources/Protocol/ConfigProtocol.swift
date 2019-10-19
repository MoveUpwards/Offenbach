//
//  ConfigProtocol.swift
//  Offenbach
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public protocol ConfigProtocol {
    static var headers: [String: String]? { get }

    var baseURL: String { get }

    var env: ApiEnvironment { get set }
    var decoder: JSONDecoder { get set }

    init(env: ApiEnvironment, decoder: JSONDecoder)
}
