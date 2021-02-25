//
//  PushnamiNotificationCenterDelegate.swift
//  Pushnami
//
//  Created by Alex on 9/4/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import UserNotifications

struct ActionButtonsResponse: Codable {
    let identifier : String;
    var actionName : String;
    let destinationUrl : String?;
    let deepLink : String?;
    let deepLinkFallback : String?;
    let payload : [String: String]?;
}

@available(iOS 10.0, *)
public class PushnamiUNUserNotificationCenterDelegate : NSObject, UNUserNotificationCenterDelegate  {
    private var categories : Set<UNNotificationCategory> = [];
    
    
    public override init(){
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // Observe events when notification buttons are included in the FCM paylaod
        NotificationCenter.default.addObserver(self, selector: #selector(self.registerNotificationAction), name: Notification.Name("com.pushnami.add-notification-button"), object: nil)
    }
    
    // Register notification actions (buttons)
    @objc public func registerNotificationAction(notification: NSNotification) {
        let clickAction: String = notification.userInfo?["click_action"] as? String ?? "pushnami-runtime-custom";
        var buttons: [UNNotificationAction] = []

        // Decode JSON action buttons response
        let actionButtons = PushnamiUtils.parseActionButtons(userInfo: notification.userInfo)
        for actionButton in actionButtons {
            var identifier = actionButton.identifier;
            if ((actionButton.destinationUrl) != nil) {
                // Add destination URL for given action
                identifier = "pushnamiOpen:\(actionButton.destinationUrl!)"
            }
            let button = UNNotificationAction(identifier: identifier, title: actionButton.actionName, options: [.foreground])
            buttons.append(button)
        }
        // Create new category with specified actions
        let category = UNNotificationCategory(identifier: clickAction, actions: buttons, intentIdentifiers: [], options: [])
        self.addCategory(category: category)
    }
  
    // Register a new category
    public func addCategory(category : UNNotificationCategory) {
        // If the category has been registered, remove it
        if let categoryIndex = self.categories.firstIndex(where: { $0.identifier == category.identifier }) {
            self.categories.remove(at: categoryIndex)
        }
        
        // Register category
        self.categories.insert(category)
        UNUserNotificationCenter.current().setNotificationCategories(self.categories)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        if (Environment.showNotificationsInForeground == true) {
            withCompletionHandler([.alert, .sound, .badge])
        }
    }
    
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Pushnami.didOpenNotification(notificationData: response.notification.request.content.userInfo, response : response);
    }
}
