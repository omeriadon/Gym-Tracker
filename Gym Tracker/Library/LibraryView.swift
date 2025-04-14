//
    //  LibraryView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                    // Add the gradient background
                GradientBackgroundView.random()
                
                VStack {
                    
                    Spacer()
                        .frame(height: 15)
                    
                    
                    List {
                        
                        Section {
                            
                            NavigationLink {
                                ExercizeListView()
                            } label: {
                                Label("Exercizes", systemImage: "figure.walk")
                                    .frame(height: 40)
                            }
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        Section {
                            
                            NavigationLink {
                                ExerciseGroupListView()
                            } label: {
                                Label("Exercize Groups", systemImage: "square.stack")
                                    .frame(height: 40)
                            }
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        Section {
                            
                            NavigationLink {
                                BookmarksView()
                            } label: {
                                Label("Bookmarks", systemImage: "bookmark")
                                    .frame(height: 40)

                            }
                            
                        }
                        .listRowBackground(UltraThinView())
                        

                        
                    }
                    .scrollContentBackground(.hidden)
                    
 
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                
                
            }
            
            .navigationTitle("Library")
        }
    }
}

#Preview {
    LibraryView()
}
