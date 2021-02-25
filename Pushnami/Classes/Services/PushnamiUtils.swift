//
//  PushnamiUtils.swift
//  MyFramework
//
//  Created by Alex on 7/25/19.
//  Copyright © 2019 pushnami. All rights reserved.
//

import Foundation
import MobileCoreServices
import UserNotifications
import UIKit

@available(iOS 10.0, *)
internal class PushnamiUtils {
    public init() {}
    
    public static func log(message : String, logLevel : LogLevel) {
        if (logLevel == LogLevel.VERBOSE && Environment.verbose != true) {
            return;
        }
        
        print("[PUSHNAMI] | \(logLevel) | \(message)")
    }
    
    // Opens the default web browser with a URL
    public static func openUrl(scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in })
        }
    }
    
    
    public static func openDeepLinkUrl(scheme : String, fallback : String) {
        if let url = URL(string: scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                self.openUrl(scheme: fallback)
            }
        }
    }
    
    // Performs a HTTP request
    public static func request<T: Decodable>(
        with url: String,
        objectType: T.Type,
        method: String? = "GET",
        body: Data? = nil,
        headers : [String : String]? = nil,
        completion: @escaping (PushnamiResult<T>) -> Void) {
        
        // Create the url with NSURL
        let dataURL = URL(string: url)! //change the url
        
        // Create the session object
        let session = URLSession.shared
        
        // Now create the URLRequest object using the url object
        var request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = method
        
        // Add HTTP request body
        if (body != nil) {
            request.httpBody = body;
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        }
        
        // Add HTTP request headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            // Return HTTP error
            guard error == nil else {
                completion(PushnamiResult.failure(PushnamiError.networkError(error!)))
                return
            }
            
            // Return no data error
            guard let data = data else {
                completion(PushnamiResult.failure(PushnamiError.dataNotFound))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode;
                if (statusCode / 100) != 2 {
                    PushnamiUtils.log(message: "Invalid HTTP status code \(statusCode) received, response : \(String(data: data, encoding: .utf8) ?? "")" , logLevel: LogLevel.ERROR)
                    completion(PushnamiResult.failure(PushnamiError.invalidStatusCode(httpResponse.statusCode)))
                    return;
                }
            }
            
            do {
                // If we're expecting a string response, return it as a decodable object
                if (objectType.self == StringApiResponse.self) {
                    let response = StringApiResponse(responseString: String(decoding: data, as: UTF8.self))
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try! jsonEncoder.encode(response)
                    let decodedObject = try JSONDecoder().decode(objectType.self, from: jsonData)
                    completion(PushnamiResult.success(decodedObject))
                    return
                }
                
                // Decode HTTP response and return
                let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
                completion(PushnamiResult.success(decodedObject))
            } catch let error {
                // Return decoding error
                completion(PushnamiResult.failure(PushnamiError.jsonParsingError(error as! DecodingError)))
            }
        })
        
        task.resume()
    }
    
    public static func processAndDisplayNotification(
        request: UNNotificationRequest,
        bestAttemptContent : UNMutableNotificationContent?,
        contentHandler: @escaping (UNNotificationContent) -> Void) {
        if let bestAttemptContent = bestAttemptContent {
            // Attempt to pull out image for notification
            if let imageString = request.content.userInfo["gcm.notification.image-url"] as? String, let imageUrl = URL(string: imageString) {
                let session = URLSession(configuration: URLSessionConfiguration.default)
                // download image
                let downloadTask = session.downloadTask(with: imageUrl) { (url, _, error) in
                    if let error = error {
                        self.log(message: "Could not download notification image attachment : \(error.localizedDescription)", logLevel: LogLevel.WARN)
                        // send notification without image now??
                    } else if let url = url {
                        let attchment = try! UNNotificationAttachment(identifier: imageString, url: url, options: [UNNotificationAttachmentOptionsTypeHintKey : kUTTypePNG])
                        bestAttemptContent.attachments = [attchment]
                    }
                    
                    // Can mutate other fields in notification payload here ex:
                    // bestAttemptContent.title = "\(bestAttemptContent.title) abcdefg"
                    
                    // Send notification with image included
                    contentHandler(bestAttemptContent)
                }
                downloadTask.resume()
            } else {
                // No image included in notification payload, send the notification as is
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    public static func parseActionButtons(userInfo: [AnyHashable: Any]?) -> [ActionButtonsResponse] {
        let buttonPayloadString = userInfo?["action-buttons"] as? String ?? "{}";
        do {
            let actionButtons = try JSONDecoder().decode([ActionButtonsResponse].self, from: buttonPayloadString.data(using: .utf8)!)
            return actionButtons
        } catch {
            return []
        }
    }
    
}
