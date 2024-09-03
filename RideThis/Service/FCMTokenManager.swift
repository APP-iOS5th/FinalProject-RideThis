//
//  FCMTokenManager.swift
//  RideThis
//
//  Created by SeongKook on 9/3/24.
//

import Foundation


class TokenManager {
    static let shared = TokenManager()
    
    var fcmToken: String?
    
    private init() {}
}
