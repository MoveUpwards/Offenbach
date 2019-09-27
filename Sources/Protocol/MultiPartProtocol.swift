//
//  MultiPartProtocol.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 27/09/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public protocol MultiPartProtocol {
    var name: String { get }
    var content: FileProtocol { get }

    init(name: String, content: FileProtocol)
}
