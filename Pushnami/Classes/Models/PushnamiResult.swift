//
//  PushnamiResult.swift
//  Pushnami
//
//  Created by Alex on 7/25/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation

// PushnamiResult enum to show success or failure
public enum PushnamiResult<T> {
    case success(T)
    case failure(PushnamiError)
}
