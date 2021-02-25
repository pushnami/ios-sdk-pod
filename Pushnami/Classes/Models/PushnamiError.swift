//
//  PushnamiError.swift
//  Pushnami
//
//  Created by Alex on 7/25/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation

public enum PushnamiError: Error {
    case networkError(Error)
    case dataNotFound
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
}
