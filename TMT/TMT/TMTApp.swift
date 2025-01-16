//
//  TMTApp.swift
//  TMT
//
//  Created by 김유빈 on 9/29/24.
//

import SwiftUI

@main
struct TMTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
