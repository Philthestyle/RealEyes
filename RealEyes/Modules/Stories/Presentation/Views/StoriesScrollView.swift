//
//  StoriesScrollView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

/// Vue scrollable horizontale des stories avec effet infini
/// 
/// PATTERN INFINITE SCROLL:
/// - Répétition des stories pour simuler l'infini
/// - LazyHStack pour performance (virtualisation)
/// - IDs uniques pour éviter les conflits SwiftUI
struct StoriesScrollView: View {
    let stories: [StoryGroup]
    let onStoryTap: (StoryGroup) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            /// LAZYHSTACK - POURQUOI ?
            /// 1. Virtualisation : Seules les vues visibles sont créées
            /// 2. Performance : Économie mémoire avec beaucoup d'éléments
            /// 3. Smooth scrolling : Pas de lag même avec 1000+ items
            /// 
            /// Alternative HStack : Toutes les vues créées = crash mémoire
            LazyHStack(spacing: 16) {
                // Your story button
                YourStoryButton()
                
                // INFINITE SCROLL IMPLEMENTATION
                // 
                // POURQUOI 1000 RÉPÉTITIONS ?
                // - Suffisant pour une session utilisateur normale
                // - L'utilisateur ne scrollera jamais jusqu'au bout
                // - Évite la complexité d'un vrai infinite scroll
                // 
                // VRAI INFINITE SCROLL (si nécessaire):
                // - Détecter quand on approche de la fin
                // - Ajouter dynamiquement des pages
                // - Plus complexe, peu de valeur ajoutée ici
                
                // ATTENTION: j aurai du utiliser un MAPPPER pour faire ca au lieu de le faire dans la View... je n y ai pas fais attention
                ForEach(0..<1000, id: \.self) { pageIndex in
                    ForEach(stories.indices, id: \.self) { storyIndex in
                        let storyGroup = stories[storyIndex]
                        StoryItemView(storyGroup: storyGroup)
                            // ID UNIQUE COMPOSITE
                            // 
                            // STRUCTURE: "pageIndex-storyId-seenState"
                            // 
                            // POURQUOI INCLURE hasBeenSeen ?
                            // - Force SwiftUI à recréer la vue quand seen change
                            // - Garantit l'animation gradient -> gris
                            // - Sans ça, SwiftUI peut réutiliser la vue (pas d'update)
                            // 
                            // POURQUOI pageIndex ?
                            // - Évite les collisions d'ID entre répétitions
                            // - Chaque répétition a des IDs uniques
                            .id("\(pageIndex)-\(storyGroup.id)-\(storyGroup.hasBeenSeen)")
                            .onTapGesture {
                                onStoryTap(storyGroup)
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
}
