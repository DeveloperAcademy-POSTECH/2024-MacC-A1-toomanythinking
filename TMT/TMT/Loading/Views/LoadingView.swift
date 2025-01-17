//
//  LoadingView.swift
//  TMT
//
//  Created by 김유빈 on 12/4/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var currentLoading: Loading = .loadingDynamic
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(currentLoading.description)
                    .title1Bold()
                    .foregroundStyle(.textDefault)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 150)

            Spacer()

            Image(currentLoading.loadingImage)

        }
        .background {
            Color.brandBackground
        }
        .ignoresSafeArea(.all)
        .onAppear {
            startAlternating()
        }
        .onDisappear {
            stopAlternating()
        }
    }

    private func startAlternating() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation {
                switchToNextLoading()
            }
        }
    }

    private func stopAlternating() {
        timer?.invalidate()
        timer = nil
    }

    private func switchToNextLoading() {
        if let currentIndex = Loading.allCases.firstIndex(of: currentLoading) {
            let nextIndex = (currentIndex + 1) % Loading.allCases.count
            currentLoading = Loading.allCases[nextIndex]
        }
    }
}

#Preview {
    LoadingView()
}
