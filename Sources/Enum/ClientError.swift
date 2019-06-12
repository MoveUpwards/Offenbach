//
//  ClientError.swift
//  Offenbach
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

/// Client error
public enum ClientError: Error {
    case noUrl
    case missingParameter
    case unknown
}
