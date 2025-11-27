//
//  ScanningView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI
import Lottie

struct ScanningView: View {
	@StateObject private var viewModel = ScanViewModel()
	
	var body: some View {
		NavigationView {
			ZStack {
				if viewModel.isScanning {
					VStack(spacing: 30) {
						LottieView.named("scanning")
							.playing(loopMode: .loop)
							.frame(width: 200, height: 200)
							.id(viewModel.isScanning)
						
						ProgressView(value: viewModel.scanProgress, total: 1.0)
							.progressViewStyle(LinearProgressViewStyle())
							.frame(width: 300)
						
						Text("Сканирование...")
							.font(.headline)
							.foregroundColor(.secondary)
						
						Text("Найдено устройств: \(viewModel.allDevices.count)")
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
				} else {
					DevicesListView(viewModel: viewModel)
				}
			}
			.navigationTitle("Сканирование")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if viewModel.isScanning {
						Button("Остановить") {
							viewModel.stopScanning()
						}
					} else {
						Button("Сканировать") {
							viewModel.startScanning()
						}
					}
				}
			}
			.alert("Ошибка", isPresented: $viewModel.showError) {
				Button("OK", role: .cancel) { }
			} message: {
				Text(viewModel.errorMessage ?? "Неизвестная ошибка")
			}
			.alert("Успешно", isPresented: $viewModel.showSuccess) {
				Button("OK", role: .cancel) { }
			} message: {
				Text(viewModel.successMessage)
			}
		}
	}
}

#Preview {
	ScanningView()
}
