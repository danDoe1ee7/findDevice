//
//  MainTabView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI

struct MainTabView: View {
	var body: some View {
		TabView {
			ScanningView()
				.tabItem {
					Label("Сканирование", systemImage: "antenna.radiowaves.left.and.right")
				}
			
			HistoryView()
				.tabItem {
					Label("История", systemImage: "clock.arrow.circlepath")
				}
		}
	}
}

#Preview {
	MainTabView()
}
