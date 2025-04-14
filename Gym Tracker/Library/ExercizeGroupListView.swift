    //
    //  ExercizeGroupListView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 13/4/2025.
    //

import SwiftUI

struct ExerciseGroupListView: View {
    
    
    
    
    var body: some View {
        
        
        
        
        NavigationStack {
            ZStack {
                    // Add the gradient background
                GradientBackgroundView.random()
                
                
                VStack {
                    Spacer()
                        .frame(height: 5)
                    
                    
                    List(exerciseGroups, id: \.id) { exercizeGroup in
                        
                        Section {
                            
                            NavigationLink {
                                ExercizeGroupDetailView(name: exercizeGroup.name)
                            } label: {
                                Label("\(exercizeGroup.name)", systemImage: "square.stack")
                                    .frame(height: 40)
                            }
                            
                            
                            
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                    }
                    
                }
                .scrollContentBackground(.hidden)
                
                
                
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                
            }

            .navigationTitle("Exercize Groups")
        }
    }
}

#Preview {
    ExerciseGroupListView()
}
