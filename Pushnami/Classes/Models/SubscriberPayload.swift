//
//  SubscriberPayload.swift
//  Pushnami
//
//  Created by Alex on 7/25/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation

struct SubscriberInfo: Codable {
    let registration_token : String;
    let platform : String;
    let appId : String;
}

struct SubscriberPayload: Codable {
    let websiteId : String;
    let subscriberId : String?;
    let channel : String;
    let urlParams : [String: String]?;
    let sub : SubscriberInfo;
}

struct SubscriberVariableUpdatePayload: Codable {
    let websiteId : String;
    let subscriberId : String;
    let urlParams : [String: String];
    let sub : [String: String] = [:]
}

struct DeactivationPayload: Codable {
    let state : String;
    let subscriberId : String;
}
