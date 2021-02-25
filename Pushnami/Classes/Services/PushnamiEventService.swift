//
//  PushnamiEventService.swift
//  Pushnami
//
//  Created by Alex on 9/3/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
internal class PushnamiEventService {
    public init() {}
    
    // Notification was received
    public static func didReceiveNotification(request: UNNotificationRequest, bestAttemptContent : UNMutableNotificationContent?, contentHandler: @escaping (UNNotificationContent) -> Void) {
        // Register delivery stat
        PushnamiEventTracking.trackEvent(eventName: "native-notification-delivered", notificationData: request.content.userInfo)
        // Show notification
        PushnamiUtils.processAndDisplayNotification(request: request, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
    }
    
    // Notification was opened
    public static func didOpenNotification(notificationData: [AnyHashable: Any], response: UNNotificationResponse?) {
        // Track event in push-api
        PushnamiEventTracking.trackEvent(eventName: "native-notification-clicked", notificationData: notificationData)
        
        // App is opened with a specified action identifier
        if let actionIdentifier = response?.actionIdentifier {
            // Action is configured to open up a url (from a button)
            if actionIdentifier.contains("pushnamiOpen:") {
                // Extract URL and open it in the default web browser
                let range = actionIdentifier.index(actionIdentifier.startIndex, offsetBy: 13)..<actionIdentifier.endIndex
                let destinationUrl = actionIdentifier[range]
                PushnamiUtils.openUrl(scheme: String(destinationUrl))
                return
            }
            
            // Perform appropiate action for opened notification
            switch actionIdentifier {
                case "com.apple.UNNotificationDefaultActionIdentifier":
                    performDefaultOpenedAction(notificationData: notificationData)
            default:
                var actionPayload : Dictionary<String, String> = [:]
                let actionButtons = PushnamiUtils.parseActionButtons(userInfo: notificationData)
                if let action = actionButtons.first(where: { $0.identifier == actionIdentifier }) {
                    // Follow deep link if included
                    if let deepLink = action.deepLink, let deepLinkFallback = action.deepLinkFallback {
                        PushnamiUtils.openDeepLinkUrl(scheme: deepLink, fallback: deepLinkFallback)
                        return;
                    }
                    // Otherwise, grab payload
                    actionPayload = action.payload ?? [:]
                }
                NotificationCenter.default.post(name: Notification.Name(actionIdentifier), object: nil, userInfo: actionPayload)
            }
        } else {
            performDefaultOpenedAction(notificationData: notificationData)
        }
    }
    
    private static func performDefaultOpenedAction(notificationData: [AnyHashable: Any]) {
        if let destinationUrl = notificationData["gcm.notification.destination-url"] as? String {
            PushnamiUtils.openUrl(scheme: destinationUrl)
        }
    }

    public static func receivedRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If FCM payload has action buttons, create an observable event to register the button's actions
        if let actionButtons = userInfo["gcm.notification.action-buttons"] as? String {
            let campaignId: String = userInfo["gcm.notification.campaignId"] as? String ?? "";
            let clickAction: String = userInfo["click_action"] as? String ?? "pushnami-runtime-custom-\(campaignId)";
            NotificationCenter.default.post(name: Notification.Name("com.pushnami.add-notification-button"), object: nil, userInfo: ["action-buttons": actionButtons, "click_action" : clickAction])
        }
        completionHandler(UIBackgroundFetchResult.newData)
        return;
    }
}
