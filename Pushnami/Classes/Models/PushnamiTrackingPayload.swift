//
//  PushnamiTrackingPayload.swift
//  Pushnami
//
//  Created by Alex on 8/30/19.
//  Copyright © 2019 pushnami. All rights reserved.
//


import Foundation

struct TrackingPayload: Codable {
    let event : String;
    var s : String?;
    var scope : String;
    var scopeId : String;
    let applicationId : String;
    let platform : String;
}
