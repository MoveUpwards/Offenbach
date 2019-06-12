//
//  Offenbach.swift
//  Offenbach
//
//  Created by Move Upwards on 12 juin 2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public protocol TokenProtocol {
    /// The authentication jwt token
    var jwt: String? { get set }

    /// The authentication api key
    var apiKey: String? { get set }

    static func logout()
}
