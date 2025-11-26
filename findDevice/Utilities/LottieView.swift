//
//  LottieView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
        } else if let path = Bundle.main.path(forResource: animationName, ofType: "json") {
            animationView.animation = LottieAnimation.filepath(path)
        }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        context.coordinator.animationView = animationView
        
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        animationView.play()
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }
        
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        
        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
    
    class Coordinator {
        var animationView: LottieAnimationView?
    }
}

extension LottieView {
    func playing(loopMode: LottieLoopMode = .loop) -> LottieView {
        var view = self
        view.loopMode = loopMode
        return view
    }
    
    static func named(_ name: String) -> LottieView {
        LottieView(animationName: name)
    }
}

#Preview {
	LottieView(animationName: "scanning")
}
