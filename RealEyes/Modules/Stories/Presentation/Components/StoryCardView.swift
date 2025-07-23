//
//  StoryCardView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine
import QuartzCore

// MARK: - StoryProgressDriver using CADisplayLink for smooth 60fps animations
/// Driver de progression utilisant CADisplayLink pour une animation fluide
/// 
/// POURQUOI CADISPLAYLINK PLUTÔT QUE TIMER?
/// 1. Synchronisé avec le refresh rate de l'écran (60/120 FPS)
/// 2. Pas de drift temporel (Timer peut dériver)
/// 3. Automatiquement pausé quand l'app est en background
/// 4. Meilleure intégration avec le rendu iOS
/// 5. Performance optimale pour les animations UI
/// 
/// UTILISATION DANS CE CONTEXTE:
/// - Progress bar des stories Instagram nécessite une fluidité parfaite
/// - L'utilisateur remarque immédiatement les saccades
/// - CADisplayLink garantit une progression smooth
final class StoryProgressDriver: ObservableObject {
    @Published var progress: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    private var duration: Double = 5.0
    private var pausedTime: CFTimeInterval = 0
    private var isPaused: Bool = false
    
    func start(duration: Double) {
        stop()
        self.duration = duration
        progress = 0.0
        startTime = CACurrentMediaTime()
        pausedTime = 0
        isPaused = false
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func pause() {
        guard !isPaused, let start = startTime else { return }
        isPaused = true
        pausedTime = CACurrentMediaTime() - start
        displayLink?.isPaused = true
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        startTime = CACurrentMediaTime() - pausedTime
        displayLink?.isPaused = false
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
        pausedTime = 0
        isPaused = false
        progress = 0.0
    }
    
    @objc private func updateProgress() {
        guard let start = startTime else { return }
        let elapsed = CACurrentMediaTime() - start
        let newProgress = min(elapsed / duration, 1.0)
        
        // POURQUOI CETTE VÉRIFICATION THREAD?
        // - Protection défensive : même si on ajoute à .main, certains edge cases
        // - Futur-proof : si le code évolue et qu'on change le RunLoop
        // - Bonne pratique : toujours vérifier quand on touche l'UI
        // - Performance : évite un dispatch inutile si déjà sur main
        // 
        // NOTE: Avec .add(to: .main, forMode: .common), on est toujours sur main
        // mais cette vérification ne coûte rien et évite les crashes
        if Thread.isMainThread {
            self.progress = newProgress
        } else {
            DispatchQueue.main.async {
                self.progress = newProgress
            }
        }
        
        if newProgress >= 1.0 {
            displayLink?.isPaused = true
        }
    }
}

struct StoryCardView: View {
    let storyGroup: StoryGroup
    let stories: [StoryGroup]
    @Binding var currentStoryId: String
    @Binding var showStory: Bool
    @Binding var isAnimating: Bool
    let onMarkAsSeen: (String) -> Void
    
    @StateObject private var progressDriver = StoryProgressDriver()
    @State private var currentIndex: Int = 0
    @State private var isPaused: Bool = false
    
    // HAPTIC FEEDBACK - Retour tactile premium
    // Style .heavy pour un feedback satisfaisant lors du changement de story
    // Comparable à Instagram : renforce l'immersion et la qualité perçue
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Background
                Color.black
                
                // Display current story
                if storyGroup.stories.indices.contains(currentIndex) {
                    let story = storyGroup.stories[currentIndex]
                    
                    switch story.type {
                    case .image:
                        AsyncImage(url: URL(string: story.mediaURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        }
                        .frame(width: size.width, height: size.height)
                        
                    case .video:
                        if let videoURL = URL(string: story.mediaURL) {
                            VideoPlayerView(videoURL: videoURL)
                                .frame(width: size.width, height: size.height)
                        } else {
                            StoryVideoView(videoName: story.mediaURL)
                                .frame(width: size.width, height: size.height)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tap Areas
            .overlay {
                HStack(spacing: 0) {
                    // Left tap area (30%)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleLeftTap()
                        }
                    
                    // Center area (40%) - pause/resume on long press
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.4)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            handleLongPress(pressing: pressing)
                        }, perform: {})
                    
                    // Right tap area (30%)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleRightTap()
                        }
                }
                .frame(height: size.height - 120)
                .offset(y: 60)
            }
            
            // Header Overlay
            .overlay(alignment: .top) {
                VStack(spacing: 12) {
                    // Progress bars with smooth CADisplayLink animation
                    StoryProgressBar(
                        numberOfStories: storyGroup.stories.count,
                        currentIndex: currentIndex,
                        progress: progressDriver.progress
                    )
                    .padding(.horizontal)
                    
                    // Profile header
                    HStack(spacing: 13) {
                        AsyncImage(url: storyGroup.user.profileImageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Text(String(storyGroup.user.displayName.prefix(1)))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                        }
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())

                        Text(storyGroup.user.displayName)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            progressDriver.stop()
                            withAnimation(.easeInOut) {
                                showStory = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, proxy.safeAreaInsets.top)
            }
            
            // EFFET 3D CUBE - Animation signature des stories
            // 
            // COMMENT ÇA MARCHE:
            // 1. angle(proxy) calcule l'angle selon la position horizontale
            // 2. axis: (x:0, y:1, z:0) = rotation autour de l'axe Y (vertical)
            // 3. anchor dynamique : pivot sur le bord visible pour effet réaliste
            // 4. perspective: 2.5 = profondeur modérée (ni trop plat, ni trop déformé)
    // 
    // MATH DERRIÈRE L'EFFET:
    // - Position X négative = story à gauche = rotation positive
    // - Position X positive = story à droite = rotation négative
    // - Crée l'illusion d'un cube 3D qui tourne
    .rotation3DEffect(
        angle(proxy),
        axis: (x: 0, y: 1, z: 0),
        anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
        perspective: 2.5
    )
        }
        .onChange(of: progressDriver.progress) { newProgress in
            if newProgress >= 1.0 && !isPaused {
                moveToNextStory()
            }
        }
        .onAppear {
            startCurrentStory()
            // Prepare haptic engine
            impactFeedback.prepare()
        }
        .onDisappear {
            progressDriver.stop()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleLeftTap() {
        if currentIndex > 0 {
            currentIndex -= 1
            startCurrentStory()
        } else {
            updateStoryGroup(forward: false)
        }
    }
    
    private func handleRightTap() {
        if currentIndex < storyGroup.stories.count - 1 {
            currentIndex += 1
            startCurrentStory()
        } else {
            // Mark as seen when we've viewed all stories and tap to go next
            onMarkAsSeen(storyGroup.id)
            updateStoryGroup(forward: true)
        }
    }
    
    private func handleLongPress(pressing: Bool) {
        isPaused = pressing
        if pressing {
            progressDriver.pause()
        } else {
            progressDriver.resume()
        }
    }
    
    private func startCurrentStory() {
        guard storyGroup.stories.indices.contains(currentIndex) else { return }
        let duration = storyGroup.stories[currentIndex].duration
        progressDriver.start(duration: duration)
    }
    
    private func moveToNextStory() {
        if currentIndex < storyGroup.stories.count - 1 {
            currentIndex += 1
            startCurrentStory()
        } else {
            // Mark as seen when we've viewed all stories in the group
            print("📍 Calling onMarkAsSeen for \(storyGroup.user.username) after viewing all \(storyGroup.stories.count) stories")
            onMarkAsSeen(storyGroup.id)
            updateStoryGroup(forward: true)
        }
    }
    
    private func updateStoryGroup(forward: Bool) {
        progressDriver.stop()
        
        guard let groupIndex = stories.firstIndex(where: { $0.id == storyGroup.id }) else { return }
        
        if forward {
            if groupIndex < stories.count - 1 {
                let nextStoryId = stories[groupIndex + 1].id
                
                // HAPTIC FEEDBACK SYNCHRONISÉ
                // Déclenché précisément au moment du changement de story group
                // Renforce la sensation de "passage" entre les stories
                // L'utilisateur "sent" littéralement le swipe
                impactFeedback.impactOccurred()
                
                // Trigger smooth animation
                DispatchQueue.main.async {
                    StoryNavigationHandler.navigateToStory(nextStoryId, currentStoryId: self.$currentStoryId)
                }
            } else {
                // Last story group - just close
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.showStory = false
                    }
                }
            }
        } else {
            if groupIndex > 0 {
                let prevStoryId = stories[groupIndex - 1].id
                
                // Haptic feedback when changing story group
                impactFeedback.impactOccurred()
                
                // Trigger smooth animation
                DispatchQueue.main.async {
                    StoryNavigationHandler.navigateToStory(prevStoryId, currentStoryId: self.$currentStoryId)
                }
            } else {
                currentIndex = 0
                startCurrentStory()
            }
        }
    }

    private func angle(_ proxy: GeometryProxy) -> Angle {
        // CALCUL DE L'ANGLE DE ROTATION 3D
        // 
        // frame(in: .global) : Position absolue dans l'écran
        // - Nécessaire car on veut la position par rapport à l'écran, pas au parent
        // - .local donnerait la position dans le TabView (toujours 0)
        // 
        // FORMULE:
        // progress = position X / largeur de la vue
        // - Story centrée : minX ≈ 0, progress ≈ 0, angle ≈ 0°
        // - Story à gauche : minX < 0, progress négatif, rotation dans un sens
        // - Story à droite : minX > 0, progress positif, rotation opposée
        // 
        // rotationAngle = 45° : Angle max pour un effet cube prononcé
        // - Trop petit (< 30°) : effet trop subtil
        // - Trop grand (> 60°) : déformation excessive
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        return Angle(degrees: Double(degrees))
    }
}
