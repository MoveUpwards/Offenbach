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
    var token: String? { get set }
}
