//
//  PushnamiSubscriptionService.swift
//  Pushnami
//
//  Created by Alex on 9/3/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import UserNotifications
import AdSupport

@available(iOS 10.0, *)
internal class PushnamiSubscriptionService {
    public init() {/* Unused since this is effetively a static singleton */}
    
    /*********************************************************************************************/
    /************ BEGIN: Pending subscriber variables member, storage key, and setter ************/
    /*********************************************************************************************/
    
    //Persistent storage key for the pending subscriber variables
    private static let STORAGE_PENDING_SUBSCRIBER_VARIABLES = "_PUSHNAMI_PENDING_SUBSCRIBER_VARIABLES";
    
    //Lazy-loaded pending subscriber variables member variable
    private static var pendingSubscriberVariables: [String: String] = {
        PushnamiUtils.log(message: "Loading pending subscriber variables from persistent storage", logLevel: LogLevel.VERBOSE);
        let data = UserDefaults.standard.dictionary(forKey: PushnamiSubscriptionService.STORAGE_PENDING_SUBSCRIBER_VARIABLES);
        guard let existingData = data else {
            return [:];
        }
        var typesafeDict = [String: String]();
        for (key, value) in existingData {
            if let value = value as? String { typesafeDict[key] = value }
        }
        return typesafeDict;
    }();
    
    //Setter for updating the pending subscriber variables member variable and saving it to persistent storage
    private static func savePendingSubscriberVariables(variables: [String: String]?) {
        /* This member variable is lazy loaded, so we will make sure it is initialized before we try and update what is in persistent storage.
           It is intentional that we assign this to a variable that is never used! */
        let unused = PushnamiSubscriptionService.pendingSubscriberVariables;
        if unused == PushnamiSubscriptionService.pendingSubscriberVariables { } // No-op to avoid build warning
        
        /* Passing a nil value for "variables" will result in wiping the subscriber variables from the device's storage, but we will keep them
           around in memory until the application is closed.  We do this just incase variables are updated while a request to the API is being
           sent, and also because it is similar to how the WebPush update routine works. */
        var variablesToSave: [String: String] = [:];
        if let variables = variables {
            PushnamiUtils.log(message: "Saving pending subscriber variables to persistent storage", logLevel: LogLevel.VERBOSE);
            PushnamiSubscriptionService.pendingSubscriberVariables.merge(variables){ (_, new) in new };
            variablesToSave = PushnamiSubscriptionService.pendingSubscriberVariables;
        } else {
            PushnamiUtils.log(message: "Wiping pending subscriber variables from persistent storage", logLevel: LogLevel.VERBOSE);
        }
        UserDefaults.standard.set(variablesToSave, forKey: PushnamiSubscriptionService.STORAGE_PENDING_SUBSCRIBER_VARIABLES);
    }
    
    /*********************************************************************************************/
    /************ BEGIN: Subscription status member variable, storage key, and setter ************/
    /*********************************************************************************************/
    
    //Persistent storage key for the subscription status
    private static let STORAGE_SUBSCRIPTION_STATUS = "_PUSHNAMI_SUBSCRIPTION_STATUS";
    
    //Lazy-loaded subscription status member variable
    private static var subscriptionStatus: SubscriptionStatus = {
        //FIXME: Check if this device is already subscribed
        PushnamiUtils.log(message: "Loading subscription status from persistent storage", logLevel: LogLevel.VERBOSE);
        guard let subscriptionStatusString = UserDefaults.standard.string(forKey: PushnamiSubscriptionService.STORAGE_SUBSCRIPTION_STATUS) else {
            return SubscriptionStatus.notPrompted;
        }
        guard let subscriptionStatus = SubscriptionStatus(rawValue: subscriptionStatusString) else {
            return SubscriptionStatus.notPrompted;
        }
        return subscriptionStatus;
    }();
    
    //Public getter function for the subscription status (this gets exposed by the SDK to developers)
    public static func getSubscriptionStatus() -> String {
        return PushnamiSubscriptionService.subscriptionStatus.rawValue;
    }
    
    //Setter for updating the subscription status member variable and saving it to persistent storage
    private static func saveSubscriptionStatus(subscriptionStatus: SubscriptionStatus) {
        PushnamiUtils.log(message: "Setting subscription status: \(subscriptionStatus)", logLevel: LogLevel.VERBOSE);
        PushnamiSubscriptionService.subscriptionStatus = subscriptionStatus;
        UserDefaults.standard.set(PushnamiSubscriptionService.subscriptionStatus.rawValue, forKey: PushnamiSubscriptionService.STORAGE_SUBSCRIPTION_STATUS);
    }
    
    /*********************************************************************************************/
    /*************** BEGIN: Subscriber ID member variable, storage key, and setter ***************/
    /*********************************************************************************************/
    
    //Persistent storage key for the subscriber ID
    private static let STORAGE_SUBSCRIPTION_ID = "_PUSHNAMI_SUBSCRIPTION_ID";
    
    //Lazy-loaded subscriber ID member variable
    private static var subscriptionId: String? = {
        PushnamiUtils.log(message: "Loading subscription ID from persistent storage", logLevel: LogLevel.VERBOSE);
        return UserDefaults.standard.string(forKey: PushnamiSubscriptionService.STORAGE_SUBSCRIPTION_ID);
    }();
    
    //Public getter function for the subscriber ID (this gets exposed by the SDK to developers)
    public static func getSubscriptionId() -> String? {
        return PushnamiSubscriptionService.subscriptionId;
    }
    
    //Setter for updating the subscriber ID member variable and saving it to persistent storage
    private static func saveSubscriptionId(subscriptionId: String) {
        PushnamiUtils.log(message: "Setting subscription ID: \(subscriptionId)", logLevel: LogLevel.VERBOSE);
        PushnamiSubscriptionService.subscriptionId = subscriptionId;
        UserDefaults.standard.set(PushnamiSubscriptionService.subscriptionId, forKey: PushnamiSubscriptionService.STORAGE_SUBSCRIPTION_ID);
    }
    
    /*********************************************************************************************/
    /*********** BEGIN: Registration token member variable, storage key, and setter **************/
    /*********************************************************************************************/
    
    //Persistent storage key for the registration token
    private static let STORAGE_REGISTRATION_TOKEN = "_PUSHNAMI_REGISTRATION_TOKEN";
    
    //Lazy-loaded registration token member variable
    private static var registrationToken: String? = {
        PushnamiUtils.log(message: "Loading registration token from persistent storage", logLevel: LogLevel.VERBOSE);
        return UserDefaults.standard.string(forKey: PushnamiSubscriptionService.STORAGE_REGISTRATION_TOKEN);
    }();
    
    //Setter for updating the registration token member variable and saving it to persistent storage
    private static func saveRegistrationToken(registrationToken: String) {
        PushnamiUtils.log(message: "Setting registration token: \(registrationToken)", logLevel: LogLevel.VERBOSE);
        PushnamiSubscriptionService.registrationToken = registrationToken;
        UserDefaults.standard.set(PushnamiSubscriptionService.registrationToken, forKey: PushnamiSubscriptionService.STORAGE_REGISTRATION_TOKEN);
    }
    
    /*********************************************************************************************/
    /************ BEGIN: Advertisement identifier variable, storage key, and setter **************/
    /*********************************************************************************************/
    
    //Persistent storage key for the registration token
    private static let STORAGE_AD_IDENTIFIER_TOKEN = "_PUSHNAMI_ADVERTISEMENT_IDENTIFIER";
    
    //Lazy-loaded registration token member variable
    private static var adIdentifier: String? = {
        PushnamiUtils.log(message: "Loading advertisement identifier from persistent storage", logLevel: LogLevel.VERBOSE);
        return UserDefaults.standard.string(forKey: PushnamiSubscriptionService.STORAGE_AD_IDENTIFIER_TOKEN);
    }();
    
    //Setter for updating the registration token member variable and saving it to persistent storage
    private static func saveAdIdentifier(adIdentifier: String) {
        PushnamiUtils.log(message: "Setting advertisement identifier: \(adIdentifier)", logLevel: LogLevel.VERBOSE);
        PushnamiSubscriptionService.adIdentifier = adIdentifier;
        UserDefaults.standard.set(PushnamiSubscriptionService.adIdentifier, forKey: PushnamiSubscriptionService.STORAGE_AD_IDENTIFIER_TOKEN);
    }
    
    /*********************************************************************************************/
    /******************** END: Special member variables, getters, and setters ********************/
    /*********************************************************************************************/
    
    //Attempt to start the registration process which allows us to request a registration token from FCM
    private static func attemptRemoteNotificationRegistration() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    //Invokes the prompt for collection permission to receive notifications
    public static func promptForNotificationsPermission() {
        // Check if the user has already been prompted
        let subscriptionStatus = PushnamiSubscriptionService.subscriptionStatus
        if (subscriptionStatus != .notPrompted) {
            var message: String;
            switch subscriptionStatus {
            case .subscribed:
                message = "accepted"
            case .unsubscribed:
                message = "accepted, but then later revoked,"
            default:
                message = "denied"
            }
            PushnamiUtils.log(message: "User has already been prompted and has \(message) permissions to send push notifications", logLevel: LogLevel.VERBOSE)
            return;
        }
        
        PushnamiSubscriptionService.saveSubscriptionStatus(subscriptionStatus: SubscriptionStatus.prompted)
        PushnamiEventTracking.trackEvent(eventName: "native-optin-shown", notificationData: ["scope" : "Application", "scopeId" : Environment.applicationId])
        
        //Track that the opt-in has been called up for this device
        
        //Display the iOS prompt for permission to receive notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                PushnamiUtils.log(message: "Permission to send notifications was denied", logLevel: LogLevel.VERBOSE)
                PushnamiEventTracking.trackEvent(eventName: "native-optin-dismissed", notificationData: ["scope" : "Application", "scopeId" : Environment.applicationId])
                return
            }
            PushnamiUtils.log(message: "Permission granted: \(granted)", logLevel: LogLevel.VERBOSE)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                PushnamiUtils.log(message: "Notification settings: \(settings)", logLevel: LogLevel.VERBOSE)
                guard settings.authorizationStatus == .authorized else { return }
                attemptRemoteNotificationRegistration()
            }
        }
    }
    
    /* Creates a new subscriber via the API with the provided registration token.  If successful we will also store some information about this subscription
       in our persistent data-store. */
    public static func createSubscriber(registrationToken : String) {
        //Do not attempt to create/re-subscribe a subscriber if they are already subscribed
        if PushnamiSubscriptionService.subscriptionStatus == .subscribed {
            return
        }
        
        //Gather all the bits of information required by our API
        let subscriberPostUrl = "\(Environment.apiUrl)/api/push/subscribe";
        let subInfo = SubscriberInfo(registration_token: registrationToken, platform: "fcm-ios", appId: Environment.applicationId);
        let pendingSubscriberVariables: [String: String] = PushnamiSubscriptionService.pendingSubscriberVariables;
        let subscriberPayload = SubscriberPayload(
            websiteId: Environment.websiteId,
            subscriberId: PushnamiSubscriptionService.subscriptionId, //Re-subscribers existing subscribers
            channel: "native",
            urlParams: pendingSubscriberVariables,
            sub: subInfo
        );
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(subscriberPayload)
        let createSubscriberHeaders = ["key" : Environment.apiKey]
        
        /* Send the "new subscriber" request to the API and handle any errors.  If successful, we will attempt to store all the vital information
           about this subscriber in our persistent data-store. */
        return PushnamiUtils.request(
            with: subscriberPostUrl,
            objectType: PushnamiCreateSubscriberResponse.self,
            method: "POST",
            body: jsonData,
            headers : createSubscriberHeaders) { (result: PushnamiResult) in
                switch result {
                case .success(let pushnamiCreateSubscriberResponse):
                    let psid: String = pushnamiCreateSubscriberResponse.subscriberId;
                    PushnamiUtils.log(message: "Created subscriber for registration token \(registrationToken) and PSID \(psid)", logLevel: LogLevel.VERBOSE);
                    PushnamiSubscriptionService.saveRegistrationToken(registrationToken: registrationToken);
                    PushnamiSubscriptionService.saveSubscriptionStatus(subscriptionStatus: SubscriptionStatus.subscribed);
                    PushnamiSubscriptionService.saveSubscriptionId(subscriptionId: psid);
                    //Since the subscriber variables were successfully sent with this new subscriber we can now reset the pending variables datastructure
                    PushnamiSubscriptionService.savePendingSubscriberVariables(variables: nil);
                case .failure(let error):
                    if Environment.verbose {
                        PushnamiUtils.log(message: "Error creating subscriber for registration token \(registrationToken) : \(error.localizedDescription)", logLevel: LogLevel.ERROR)
                    }
                }
        }
    }
    
    public static func deactivateSubscriber() {
        //If the device is currently subscribed, then deactivate the subscriber
        if PushnamiSubscriptionService.subscriptionStatus != .subscribed {
            return
        }
        //Must have a subscriber ID in order to deactivate
        guard let subscriberId = PushnamiSubscriptionService.subscriptionId else { return }
        
        /* Send the request to deactivate the existing subscriber to the API and handle any errors.  If successful then we will update the information
           about this subscriber in our persistent data-store. */
        let subscriberPostUrl = "\(Environment.apiUrl)/api/push/unsubscribe";
        let deactivationPayload = DeactivationPayload(state: "blocked", subscriberId: subscriberId);
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(deactivationPayload)
        let deactivateSubscriberHeaders = ["key" : Environment.apiKey]
        return PushnamiUtils.request(
            with: subscriberPostUrl,
            objectType: PushnamiDeactivateSubscriberResponse.self,
            method: "POST",
            body: jsonData,
            headers : deactivateSubscriberHeaders) { (result: PushnamiResult) in
                switch result {
                case .success:
                    PushnamiUtils.log(message: "Deactivated subscriber with PSID \(subscriberId)", logLevel: LogLevel.VERBOSE);
                    PushnamiSubscriptionService.saveSubscriptionStatus(subscriptionStatus: SubscriptionStatus.unsubscribed);
                case .failure(let error):
                    if Environment.verbose {
                        PushnamiUtils.log(message: "Error deactivating subscriber with PSID \(subscriberId) : \(error.localizedDescription)", logLevel: LogLevel.ERROR)
                    }
                }
        }
    }
    
    /* Attempts to update the subscriber variables (via the API) of the existing subscriber.  If no subscriber has been created yet, then we will simply updating
       the pending set of subscriber variables with those provided to this function call (the subscription process will automatically absorb them later).
       NOTICE: This function can be called with nil variables, which can be used to force any pending subscriber variables to be sent to the API (once again, provided
               that a subscriber has already been created). */
    public static func updateSubscriberVariables(variables : [String: String]? = nil) {
        //Update the pending subscriber variables (if necessary)
        if let variables = variables {
            PushnamiSubscriptionService.savePendingSubscriberVariables(variables: variables);
        }
        
        // Until the user subscribes we cannot send the subscriber variables to the API, so we will just remember them
        var pendingVariables: [String: String] = PushnamiSubscriptionService.pendingSubscriberVariables;
        let hasPendingVariables: Bool = !pendingVariables.isEmpty;
        let isSubscribed: Bool = PushnamiSubscriptionService.subscriptionStatus == SubscriptionStatus.subscribed;
        let subscriberId: String = PushnamiSubscriptionService.subscriptionId ?? "";
        let hasSubscriberId: Bool = !subscriberId.isEmpty
        if (hasPendingVariables && isSubscribed && hasSubscriberId) {
            // Since this device is already subscribed we will just update their subscriber variables through the API
            pendingVariables["svu"] = "true"; //This is required to tell the API that this is an explicit "subscriber variable update" call
            let subVarsUpdatePostUrl: String = "\(Environment.apiUrl)/api/push/subscribe";
            let payload = SubscriberVariableUpdatePayload(websiteId: Environment.websiteId, subscriberId: subscriberId, urlParams: pendingVariables)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(payload)
            let createSubVarsUpdateHeaders = ["key" : Environment.apiKey]
            PushnamiUtils.request(
                with: subVarsUpdatePostUrl,
                objectType: PushnamiCreateSubscriberResponse.self,
                method: "POST",
                body: jsonData,
                headers : createSubVarsUpdateHeaders) { (result: PushnamiResult) in
                    switch result {
                    case .success:
                        PushnamiUtils.log(message: "Updated subscriber variables for PSID \(subscriberId)", logLevel: LogLevel.VERBOSE);
                        //Since the subscriber variables were successfully updated we can now reset the pending variables datastructure
                        PushnamiSubscriptionService.savePendingSubscriberVariables(variables: nil);
                    case .failure(let error):
                        if Environment.verbose {
                            PushnamiUtils.log(message: "Error updating subscriber variables for PSID \(subscriberId) : \(error.localizedDescription)", logLevel: LogLevel.ERROR)
                        }
                    }
            }
        }
    }
    
    // Registers FCM token on app start
    public static func registrationTokenReceived(fcmToken : String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    public static func verifySubscription() {
        //Check if we can get the identifier for serving advertisements
        let asIdentifierManager = ASIdentifierManager.shared()
        if asIdentifierManager.isAdvertisingTrackingEnabled {
            let adIdentifier: UUID = asIdentifierManager.advertisingIdentifier
            let adIdentifierString: String = adIdentifier.uuidString
            let currentAdIdentifier = PushnamiSubscriptionService.adIdentifier
            if adIdentifierString != currentAdIdentifier {
                PushnamiSubscriptionService.saveAdIdentifier(adIdentifier: adIdentifierString)
                PushnamiSubscriptionService.updateSubscriberVariables(variables: ["aaid": adIdentifierString])
            }
        }
        
        //Check the permissions of the application and subscribe/unsubscribe the device as necessary
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                PushnamiSubscriptionService.deactivateSubscriber()
            case .authorized:
                if let registrationToken = PushnamiSubscriptionService.registrationToken {
                    PushnamiSubscriptionService.createSubscriber(registrationToken: registrationToken)
                } else {
                    attemptRemoteNotificationRegistration()
                }
            case .denied:
                PushnamiSubscriptionService.deactivateSubscriber()
            default:
                if Environment.verbose {
                    PushnamiUtils.log(message: "Unsupported notification settings authorization status: \(settings.authorizationStatus)", logLevel: LogLevel.ERROR)
                }
            }
        }
    }
}
