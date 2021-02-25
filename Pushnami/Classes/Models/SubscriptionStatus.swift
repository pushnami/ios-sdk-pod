//
//  SubscriptionStatus.swift
//  Pushnami
//
//  Created by Jonathan Vasek on 9/11/19.
//

import Foundation

internal enum SubscriptionStatus: String {
    case notPrompted = "NOT_PROMPTED"
    case prompted = "PROMPTED"
    case subscribed = "SUBSCRIBED"
    case unsubscribed = "UNSUBSCRIBED"
}
