//
//  View.swift
//  TMT
//
//  Created by 김유빈 on 11/23/24.
//

import SwiftUI

enum Detents {
    case small
    case middle
    case large
    
    var presentationDetent: PresentationDetent {
        switch self {
        case .small:
            return .height(64)
        case .middle:
            return .height(525)
        case .large:
            return .fraction(0.999)
        }
    }
}

extension View {
    @ViewBuilder
    func bottomSheet<Content: View>(
        presentationDetents: [Detents] = [.small, .middle, .large],
        isPresented: Binding<Bool> = .constant(true),
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat = 16,
        interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .sheet(isPresented: isPresented) {
            } content: {
                content()
                    .presentationDetents(Set(presentationDetents.map { $0.presentationDetent }))
                    .presentationDragIndicator(dragIndicator)
                    .interactiveDismissDisabled(interactiveDisabled) // 시트 안 닫히도록 설정
                    .presentationBackgroundInteraction(.enabled) // sheet 뒷 배경과 인터랙션 가능
                    .presentationCornerRadius(sheetCornerRadius)
                //                    .background(Color.red) // TODO: 배경색 수정
                    .onAppear{
                        // TODO: 필요한가?
                    }
            }
    }
}
