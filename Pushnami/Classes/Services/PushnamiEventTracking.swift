//
//  PushnamiEventTracking.swift
//  Pushnami
//
//  Created by Alex on 7/28/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import UserNotifications

// Construct a JSON encoded payload to send to tracking url
func getTrackingPayload(event : String,  notificationData: [AnyHashable: Any]) -> Data {
    var trackingPayload = TrackingPayload(event: event, s: nil, scope: "", scopeId: "", applicationId : Environment.applicationId, platform : "fcm-ios")
    
    if let subscriberId = notificationData["gcm.notification.subscriberId"] as? String {
        trackingPayload.s = subscriberId;
    }
    
    if let campaignId = notificationData["gcm.notification.campaignId"] as? String {
        trackingPayload.scope = "Campaign"
        trackingPayload.scopeId = campaignId;
    }
    
    if let scope = notificationData["scope"] as? String {
        trackingPayload.scope = scope
    }
    
    if let scopeId = notificationData["scopeId"] as? String {
        trackingPayload.scopeId = scopeId
    }

    let jsonEncoder = JSONEncoder()
    let jsonData = try! jsonEncoder.encode(trackingPayload)
    return jsonData
}

@available(iOS 10.0, *)
internal class PushnamiEventTracking {
    public init() {}
    
    // Track events through push-api
    public static func trackEvent(eventName : String, notificationData: [AnyHashable: Any]) {
        let trackingUrl = "\(Environment.pushTrackingUrl)/api/push/track";
        let trackingPayload = getTrackingPayload(event: eventName, notificationData: notificationData)

        PushnamiUtils.request(with: trackingUrl, objectType: StringApiResponse.self, method: "POST", body: trackingPayload) { (result: PushnamiResult) in
            switch result {
            case .success:
                PushnamiUtils.log(message: "Tracked event \(eventName)", logLevel: LogLevel.VERBOSE)
            case .failure(let error):
                PushnamiUtils.log(message: "Error tracking event \(eventName) \(error.localizedDescription)", logLevel: LogLevel.ERROR)
            }
        }
    }
}
