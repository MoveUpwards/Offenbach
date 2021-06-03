//
//  Offenbach.swift
//  Offenbach
//
//  Created by Move Upwards on 12 juin 2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public protocol TokenProtocol: Decodable {
    /// The authentication jwt token
    var token: String? { get set }

    /// The authentication jwt refresh token
    var refresh: String? { get set }
}
