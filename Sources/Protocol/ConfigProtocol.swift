//
//  ConfigProtocol.swift
//  Offenbach
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Alamofire
import Foundation

public protocol ConfigProtocol {
    var headers: [HTTPHeader] { get }
    var baseURL: String { get }
    var env: ApiEnvironment { get }
    var decoder: DataDecoder { get }
    var configuration: URLSessionConfiguration { get }

    init(env: ApiEnvironment, decoder: DataDecoder)
}
