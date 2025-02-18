//
//  ImageHandlerModel.swift
//  TMT
//
//  Created by Choi Minkyeong on 11/14/24.
//

import SwiftUI
import PhotosUI

final class ImageHandlerModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var showAlertScreen: Bool = false
    @Published var showAlertText: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var scannedJourneyInfo = ScannedJourneyInfo(busNumber: "", startStop: "", endStop: "")

    let ocrStarter = OCRStarterManager()

    /// 이미지를 로드하고 OCR을 진행하여 필요한 값을 뽑아냅니다.
    func loadImageByPhotosPickerItem(from item: PhotosPickerItem?, viewCategory: String, completion: @escaping () -> Void) {
        Task {
            guard let item = item else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.selectedImage = image
                    self.isLoading = true
                    self.showAlertScreen = false
                    self.showAlertText = false
                }
                ocrStarter.startOCR(image: image) { info in
                    self.isLoading = false
                    if info.busNumber.isEmpty && info.startStop.isEmpty && info.endStop.isEmpty {
                        if viewCategory == "NotUploadedView" {
                            self.showAlertScreen = true
                        } else if viewCategory == "ScannedJourneyInfoView" {
                            self.showAlertText = true
                        }
                    } else {
                        self.scannedJourneyInfo = self.ocrStarter.splitScannedInfo(scannedJourneyInfo: info)
                    }

                    completion()
                }
            } else {
                completion()
            }
        }
    }

    func loadImagebyUIImage(from image: UIImage?, viewCategory: String, completion: @escaping () -> Void) {
        guard let image = image else { return }

        Task {
            DispatchQueue.main.async {
                self.selectedImage = image
                self.isLoading = true
                self.showAlertScreen = false
                self.showAlertText = false
            }

            ocrStarter.startOCR(image: image) { info in
                self.isLoading = false

                if info.busNumber.isEmpty && info.startStop.isEmpty && info.endStop.isEmpty {
                    if viewCategory == "NotUploadedView" {
                        self.showAlertScreen = true
                    } else if viewCategory == "ScannedJourneyInfoView" {
                        self.showAlertText = true
                    }
                } else {
                    self.scannedJourneyInfo = self.ocrStarter.splitScannedInfo(scannedJourneyInfo: info)
                }
                completion()
            }
        }
    }
}
