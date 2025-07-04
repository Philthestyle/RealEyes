# RealEyes - Instagram Stories Clone 📸

## 🎯 Test Technique - iOS Engineer

Une implémentation moderne et performante d'une feature Stories type Instagram, développée en Swift avec SwiftUI.

---

## 🏗️ Architecture & Choix Techniques

### Architecture MVVM-C (Model-View-ViewModel-Coordinator)
```
RealEyes/
├── App/                    # Configuration & Entry Point
├── Core/                   # Composants réutilisables
│   ├── DI/                # Dependency Injection Container
│   ├── Network/           # Service réseau générique
│   └── UI/                # Composants UI partagés
└── Modules/               # Features modulaires
    ├── Stories/           # Module Stories complet
    ├── Posts/             # Module Feed
    └── Home/              # Module principal
```

**Pourquoi MVVM ?**
- **Séparation des responsabilités** : La logique métier est isolée dans les ViewModels
- **Testabilité** : Les ViewModels sont facilement testables unitairement
- **Réactivité** : Avec `@Published` et `ObservableObject` pour une UI réactive
- **Scalabilité** : Chaque module est indépendant et peut évoluer séparément

### Dependency Injection Container
```swift
// Enregistrement au démarrage
container.register(NetworkService.shared)
container.register(StoryServiceProtocol.self) { StoryService() }

// Utilisation dans les ViewModels
self.storyService = DIContainer.shared.resolveOptional() ?? StoryService()
```

**Avantages :**
- Découplage des dépendances
- Facilite les tests avec des mocks
- Configuration centralisée

---

## 🚀 Features Implémentées

### 1. Story List avec Pagination Infinie

#### Implementation avec LazyHStack
```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: 16) {
        YourStoryButton()
        
        // Génération de 1000 répétitions pour l'infini
        ForEach(0..<1000, id: \.self) { pageIndex in
            ForEach(stories.indices, id: \.self) { storyIndex in
                StoryItemView(storyGroup: stories[storyIndex])
            }
        }
    }
}
```

**Optimisations Performance :**
- **LazyHStack** : Charge uniquement les vues visibles (virtualization)
- **Identifiants uniques** : `id: "\(pageIndex)-\(storyIndex)"` évite les conflits SwiftUI
- **Pas de préchargement** : Les stories sont créées à la demande

### 2. Story Viewer avec Animation 3D Cube

#### Effet 3D Cube sur TabView
```swift
.rotation3DEffect(
    angle(proxy),
    axis: (x: 0, y: 1, z: 0),
    anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
    perspective: 2.5
)

private func angle(_ proxy: GeometryProxy) -> Angle {
    let progress = proxy.frame(in: .global).minX / proxy.size.width
    let rotationAngle: CGFloat = 25
    let degrees = rotationAngle * progress
    return Angle(degrees: Double(degrees))
}
```

**Comment ça marche :**
- **GeometryReader** : Capture la position de chaque story
- **Progress calculation** : Position X / largeur = progression du swipe
- **Rotation dynamique** : L'angle change en fonction du swipe
- **Anchor point** : Pivot sur le bord pour effet cube réaliste

### 3. Progress Bar 60 FPS avec CADisplayLink

#### StoryProgressDriver Implementation
```swift
final class StoryProgressDriver: ObservableObject {
    @Published var progress: Double = 0.0
    private var displayLink: CADisplayLink?
    
    func start(duration: Double) {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateProgress() {
        let elapsed = CACurrentMediaTime() - startTime
        let newProgress = min(elapsed / duration, 1.0)
        
        if Thread.isMainThread {
            self.progress = newProgress
        } else {
            DispatchQueue.main.async {
                self.progress = newProgress
            }
        }
    }
}
```

**Pourquoi CADisplayLink ?**
- **Synchronisation avec l'écran** : S'aligne sur le refresh rate (60/120 FPS)
- **Fluidité maximale** : Pas de saccades comme avec Timer
- **Performance** : Optimisé par le système pour l'animation
- **Pause/Resume** : Support natif pour les interactions utilisateur

### 4. Persistance des États avec UserDefaults

#### Implementation dans StoryService
```swift
private let seenStoriesKey = "com.realeyes.seenStories"
private var seenStoryIds: Set<String> {
    get {
        let array = UserDefaults.standard.stringArray(forKey: seenStoriesKey) ?? []
        return Set(array)
    }
    set {
        UserDefaults.standard.set(Array(newValue), forKey: seenStoriesKey)
    }
}

func markAsSeen(_ storyId: UUID) {
    stories[index].hasBeenSeen = true
    var currentSeenIds = seenStoryIds
    currentSeenIds.insert(storyId.uuidString)
    seenStoryIds = currentSeenIds
}
```

**Avantages :**
- **Survit au kill de l'app** : Les états sont restaurés au lancement
- **Performance** : Set<String> pour lookup O(1)
- **Simplicité** : UserDefaults parfait pour ce use case

### 5. Network Layer avec Async/Await

#### Generic NetworkService
```swift
func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    return try decoder.decode(T.self, from: data)
}
```

#### Chargement Concurrent avec TaskGroup
```swift
await withTaskGroup(of: Void.self) { group in
    group.addTask { await self?.loadStories() }
    group.addTask { await self?.loadPosts() }
}
```

**Performance Benefits :**
- **Chargement parallèle** : Stories et Posts en même temps
- **Type-safe** : Generics pour décoder n'importe quel type
- **Error handling** : Gestion propre des erreurs avec fallback

### 6. Interactions Gestures Instagram-like

#### Tap Zones Implementation
```swift
HStack(spacing: 0) {
    // Zone gauche 30% - Story précédente
    Rectangle()
        .fill(Color.clear)
        .frame(width: size.width * 0.3)
        .onTapGesture { handleLeftTap() }
    
    // Zone centre 40% - Pause
    Rectangle()
        .fill(Color.clear)
        .frame(width: size.width * 0.4)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            handleLongPress(pressing: pressing)
        }, perform: {})
    
    // Zone droite 30% - Story suivante
    Rectangle()
        .fill(Color.clear)
        .frame(width: size.width * 0.3)
        .onTapGesture { handleRightTap() }
}
```

**UX Optimizations :**
- **Zones invisibles** : L'utilisateur ne voit pas les zones
- **Proportions Instagram** : 30-40-30 pour un contrôle naturel
- **Long press pour pause** : Comme Instagram

### 7. Haptic Feedback Premium 📳

#### Implementation avec UIImpactFeedbackGenerator
```swift
// Posts - Double Tap Like
private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

private func handleDoubleTapLike() {
    impactFeedback.impactOccurred()
    
    // Double tap ne fait QUE liker, jamais disliker (comme Instagram)
    if !isLiked {
        isLiked = true
        likes += 1
    }
    
    // Animation du cœur blanc dans tous les cas
    showHeartAnimation = true
}
```

#### Stories - Changement avec Animation 3D
```swift
private func updateStoryGroup(forward: Bool) {
    // Haptic feedback synchronisé avec l'animation 3D cube
    impactFeedback.impactOccurred()
    
    // Navigation vers la story suivante/précédente
    StoryNavigationHandler.navigateToStory(nextStoryId, currentStoryId: self.$currentStoryId)
}
```

**Haptic Feedback Complet :**
- **Double Tap sur Post** : 
  - Feedback `.heavy` fort et satisfaisant
  - Animation cœur blanc qui apparaît/disparaît
  - Le double tap ne dislike JAMAIS (comportement Instagram)
  - Animation bounce du bouton cœur pour feedback visuel
  
- **Single Tap Bouton Like** : 
  - Feedback `.heavy` pour toggle like/unlike
  - Animation spring du bouton
  
- **Bookmark** : 
  - Feedback `.light` plus subtil
  
- **Changement de Story** :
  - Feedback `.heavy` synchronisé avec l'animation 3D
  - Se déclenche lors du swipe entre story groups
  - Renforce l'immersion pendant la rotation cube

**Pourquoi le Haptic Feedback ?**
- **Satisfaction utilisateur** : Retour tactile immédiat
- **Confirmation d'action** : L'utilisateur sait que son action a été prise en compte
- **Immersion** : Renforce le côté premium de l'app
- **Accessibilité** : Aide les utilisateurs malvoyants

### 8. Loader Arc-en-ciel Animé 🌈

#### Rainbow Loader Component
```swift
struct RainbowLoader: View {
    private let gradient = AngularGradient(
        colors: [
            Color(red: 0.95, green: 0.42, blue: 0.31),    // Orange-red
            Color(red: 0.91, green: 0.31, blue: 0.48),    // Red-pink
            Color(red: 0.85, green: 0.25, blue: 0.62),    // Pink
            Color(red: 0.74, green: 0.28, blue: 0.79),    // Purple-pink
            Color(red: 0.53, green: 0.39, blue: 0.89),    // Purple-blue
            Color(red: 0.33, green: 0.52, blue: 0.92),    // Blue
            Color(red: 0.33, green: 0.75, blue: 0.85),    // Cyan
            Color(red: 0.95, green: 0.42, blue: 0.31)     // Back to orange-red
        ],
        center: .center
    )
}
```

**Utilisation :**
- **Launch Screen** : Loader principal sous le logo RealEyes
- **Pull to Refresh** : Version mini lors du refresh du feed
- **Animation fluide** : Rotation continue + effet de croissance du trait
- **Cohérence visuelle** : Mêmes couleurs que le gradient Instagram du logo

---

## 🎨 UI/UX Details

### Launch Screen Animé
- Logo RealEyes avec gradient Instagram
- Loader arc-en-ciel animé
- Fond noir élégant
- Transition smooth vers l'app

### Logo Instagram-Style
- **Texte "RealEyes"** avec gradient Instagram authentique
- **Couleurs** : Orange-red → Pink → Purple → Blue
- **Police** : System font bold arrondie
- **Adaptable** : S'ajuste à différentes tailles

### Story Item Design
- **Gradient ring** : Indique une story non vue
- **Gris** : Story déjà vue
- **Animation scale** : Feedback visuel au tap

### Feed Integration
- **Double tap like** : Animation cœur + haptic feedback
- **Bounce animation** : Le bouton cœur s'anime lors du like
- **Usernames stylés** : naturelover, foodie_life, etc.
- **Images haute qualité** : Unsplash pour une belle UX

---

## 📊 Logs & Monitoring

### Console Output Example
```
🏠 [HomeViewModel] Starting concurrent data loading with TaskGroup...
⚡ [HomeViewModel] Loading Stories and Posts in PARALLEL for better performance

📱 [StoryService] Starting to load stories...
🌐 [StoryService] Attempting to fetch from API: https://dummyjson.com/users?limit=10
✅ [StoryService] API SUCCESS! Fetched 10 users from dummyjson.com
🎨 [StoryService] Enhanced API data with high-quality images from Unsplash
💾 [StoryService] Restored 3 seen states from UserDefaults

📰 [PostService] Starting to load posts...
✅ [PostService] API SUCCESS! Fetched 20 posts from dummyjson.com

⏱️ [HomeViewModel] Data loaded in 0.84 seconds
🎉 [HomeViewModel] All data loaded successfully!
```

---

## 🔧 Technologies Utilisées

- **SwiftUI** : UI déclarative moderne
- **Combine** : Pour la réactivité (ObservableObject)
- **async/await** : Concurrence moderne Swift
- **CADisplayLink** : Animations 60 FPS
- **UserDefaults** : Persistance légère
- **UIImpactFeedbackGenerator** : Haptic feedback natif iOS
- **Generic NetworkService** : Type-safe API calls
- **LazyHStack** : Virtualisation pour performance

---

## 🏆 Points Forts

1. **Performance** : LazyHStack + CADisplayLink = fluidité maximale
2. **Architecture** : MVVM modulaire et scalable
3. **UX Premium** : Animations, haptic feedback et interactions fidèles à Instagram
4. **Code Quality** : Type-safe, error handling, logs détaillés
5. **Persistence** : Les états survivent au kill de l'app
6. **Feedback Tactile** : Haptic feedback sur toutes les interactions importantes

---

## 📱 Comment Tester

1. **Stories Infinies** : Scrollez à droite, ça ne s'arrête jamais
2. **Animation 3D + Haptic** : Swipez entre les stories, sentez le feedback lors du changement
3. **Persistance** : Regardez des stories, killez l'app, relancez
4. **Double Tap** : Sur les posts pour liker (ne dislike jamais) + haptic feedback
5. **Progress Bar** : Fluide à 60 FPS grâce à CADisplayLink
6. **Pull to Refresh** : Tirez vers le bas pour voir le loader arc-en-ciel
7. **Haptic Feedback** : Activez le son/vibration pour sentir tous les retours tactiles

---

*Développé avec ❤️ en 4 heures pour le test technique BeReal*
