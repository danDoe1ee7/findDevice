//
//  LaunchScreenView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI

struct LaunchScreenView: View {
	@State private var isActive = false
	@State private var size = 0.8
	@State private var opacity = 0.5
	
	var body: some View {
		if isActive {
			MainTabView()
		} else {
			ZStack {
				Color.blue.ignoresSafeArea()
				
				VStack {
					Image(systemName: "antenna.radiowaves.left.and.right")
						.font(.system(size: 80))
						.foregroundColor(.white)
						.scaleEffect(size)
						.opacity(opacity)
					
					Text("Find Device")
						.font(.largeTitle)
						.fontWeight(.bold)
						.foregroundColor(.white)
						.opacity(opacity)
				}
				.onAppear {
					withAnimation(.easeIn(duration: 1.2)) {
						self.size = 0.9
						self.opacity = 1.0
					}
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					withAnimation {
						self.isActive = true
					}
				}
			}
		}
	}
}

#Preview {
	LaunchScreenView()
}
