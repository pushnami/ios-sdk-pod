//
//  Environment.swift
//  Pushnami
//
//  Created by Alex on 7/28/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation

/* TODO: Implement a more elegant way of failing than using fatalError */
public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let apiKey = "PUSHNAMI_API_KEY"
            static let applicationId = "PUSHNAMI_APPLICATION_ID"
            static let env = "PUSHNAMI_ENVIRONMENT"
            static let verbose  = "PUSHNAMI_VERBOSE"
            static let apiUrl = "PUSHNAMI_API_URL"
            static let pushTrackingUrl = "PUSHNAMI_TRACKING_URL"
            static let websiteId = "PUSHNAMI_WEBSITE_ID"
            static let showNotificationsInForeground = "PUSHNAMI_SHOW_IN_FOREGROUND"
            static let transportSecuritySettings = "App Transport Security Settings";
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Pushnami-Info", ofType: "plist") else { fatalError("Pushnami-Info.pist file not found") }
        guard let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> else { fatalError("Pushnami-Info.pist file not found") }
        return dict
    }()
    
    static let apiKey: String = {
        guard let apiKey = Environment.infoDictionary[Keys.Plist.apiKey] as? String else {
            fatalError("Pushnami API Key not set in plist for this environment")
        }
        return apiKey
    }()
    
    static let applicationId: String = {
        guard let applicationId = Environment.infoDictionary[Keys.Plist.applicationId] as? String else {
            fatalError("Pushnami Application Id not set in plist for this environment")
        }
        return applicationId
    }()
    
    static let showNotificationsInForeground: Bool = {
        guard let showNotificationsInForeground = Environment.infoDictionary[Keys.Plist.showNotificationsInForeground] as? Bool else {
            return false;
        }
        return showNotificationsInForeground
    }()
    
    static let verbose: Bool = {
        guard let verbose = Environment.infoDictionary[Keys.Plist.verbose] as? Bool else {
            return false
        }
        return verbose
    }()
    
    /* TODO :   - come back and finish this
                - will ensure the user has correctly set up their info.plist
     */
    static let transportSecuritySettings : Bool = {
        guard let transportSecuritySettings = Environment.infoDictionary[Keys.Plist.transportSecuritySettings] as? [String : Any] else {
            print("transport settings not found")
            return false;
        }
        print(transportSecuritySettings);
        return true;
    }()
    
    static let apiUrl: String = {
        if let apiUrl = Environment.infoDictionary[Keys.Plist.apiUrl] as? String {
            return apiUrl
        }
        
        guard let env = Environment.infoDictionary[Keys.Plist.env] as? String else {
            return "https://api.pushnami.com";
        }
        
        switch env.lowercased() {
        case "production":
            return "https://api.pushnami.com"
        case "staging":
            return "https://api.staging.pushnami.com"
        case "development":
            return "http://localhost:8000/" // check pslist confiruation if http is allowed
        default:
            return "https://api.pushnami.com"
        }
    }()
    
    static let pushTrackingUrl: String = {
        if let pushTrackingUrl = Environment.infoDictionary[Keys.Plist.pushTrackingUrl] as? String {
            return pushTrackingUrl
        }
        
        guard let env = Environment.infoDictionary[Keys.Plist.env] as? String else {
            return "https://api.pushnami.com";
        }
        
        switch env.lowercased() {
        case "production":
            return "https://api.pushnami.com"
        case "staging":
            return "https://api.staging.pushnami.com"
        case "development":
            return "http://localhost:8002" // check pslist confiruation if http is allowed
        default:
            return "https://api.pushnami.com"
        }
    }()
    
    static let websiteId: String = {
        guard let websiteId = Environment.infoDictionary[Keys.Plist.websiteId] as? String else {
            fatalError("Pushnami Website ID not set in plist for this environment")
        }
        return websiteId
    }()
    
}
