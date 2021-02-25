//
//  MyFramework.swift
//  MyFramework
//
//  Created by Alex on 7/24/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
public class Pushnami {
    public init() {}
    
    /********* INITIALIZATION *********/
    public static func initialize(didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        //FIXME: Only let this function execute once!
        
        // Detect if app was launched by clicking a notification
        if let notificationData = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as! [AnyHashable : Any]? {
            Pushnami.didOpenNotification(notificationData: notificationData, response : nil);
        }
        
        PushnamiUtils.log(message: "Testing Log Statement", logLevel: LogLevel.VERBOSE)
        PushnamiUtils.log(message: "Application \(Environment.applicationId) initialized", logLevel: LogLevel.VERBOSE)
        
        //We will verify that the subscription of this device is still valid and take any appropriate action
        Pushnami.applicationEnteredForeground()
        }
    /* This should be called EVERY TIME the application enters the foreground.  It is okay to call it any other time as well, but it is important
       to call when the application enters the foreground because this will also verify that permissions have not changed since the last time
       the application was in the foreground. */
    public static func applicationEnteredForeground() { PushnamiSubscriptionService.verifySubscription() }
    
    /********* NOTIFICATION EVENT HANDLERS *********/
    public static func didReceiveNotification(request: UNNotificationRequest, bestAttemptContent : UNMutableNotificationContent?, contentHandler: @escaping (UNNotificationContent) -> Void) {
        PushnamiEventService.didReceiveNotification(request: request, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
    }
    public static func didOpenNotification(notificationData: [AnyHashable: Any], response: UNNotificationResponse?) { PushnamiEventService.didOpenNotification(notificationData: notificationData, response : response) }
    public static func receivedRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushnamiEventService.receivedRemoteNotification(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    /********* SUBSCRIPTION RELATED ACTIONS *********/
    // Prompt user for notifications permissions
    public static func promptForNotificationsPermission() { PushnamiSubscriptionService.promptForNotificationsPermission() }
    // Create subscriber with registration token
    public static func createSubscriber(registrationToken : String) { PushnamiSubscriptionService.createSubscriber(registrationToken: registrationToken) }
    // Registers FCM token on app start
    public static func registrationTokenReceived(fcmToken : String) { PushnamiSubscriptionService.registrationTokenReceived(fcmToken: fcmToken) }
    // Allows updating of the subscriber's variables
    public static func update(variable: String, value: String) { Pushnami.update(variables: [variable: value]) }
    // Allows updating of multiple subscriber variables
    public static func update(variables: [String: String]) { PushnamiSubscriptionService.updateSubscriberVariables(variables: variables) }
    
    /********* EXPOSURE OF SUBSCRIBER DATA *********/
    //Get the current subscription status of the device
    public static func getSubscriptionStatus() -> String { return PushnamiSubscriptionService.getSubscriptionStatus() }
    //Get the current subscriber ID of the device
    public static func getPSID() -> String? { return PushnamiSubscriptionService.getSubscriptionId() }
}
