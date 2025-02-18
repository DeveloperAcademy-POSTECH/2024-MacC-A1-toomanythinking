//
//  OnboardingIntroView.swift
//  TMT
//
//  Created by 김유빈 on 11/20/24.
//

import SwiftUI

struct OnboardingIntroView: View {
    private let title = "Never miss your stop\nwith BusDot"
    let screenMode: String
    
    var body: some View {
        let fileName = screenMode == "Light" ? "BusDotIntro" : "BusDotIntroDark"
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .title1Bold()
                .foregroundStyle(.textDefault)
                .padding(.top, 61)
                .padding(.horizontal, 24)
            
            Spacer()
            
            LottieView(animationFileName: fileName, loopMode: .loop)
                .frame(minHeight: 460)
                .padding(.bottom, 169)
        }
    }
}

#Preview {
    OnboardingIntroView(screenMode: "Dark")
}
