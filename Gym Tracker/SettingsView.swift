//
    //  SettingsView.swift
    //  Gym Tracker
    //
    //  Created by Adon Omeri on 12/4/2025.
    //

import SwiftUI
import SwiftData
import ColorfulX

struct SettingsView: View {
    
    @State var isDarkMode = SettingsView.isDarkModeEnabled()
    @State var units = SettingsView.getUnits()
    @State var name = SettingsView.getName()
    
        // Alert state variables
    @State var showResetSettingsAlert = false
    @State var showDeleteDataAlert = false
    @State var showResetAllAlert = false
    
    @Query var completedWorkouts: [Workout]
    
    @State var showCredits = false
    
    
    @State var colours: [Color] = [Color.green, Color.red, Color.blue, Color.teal, Color.cyan, Color.orange]
    
    @State var speed: Double = 1
    
    @State var noise: Double = 20
    
    @State private var selectedWorkout: Workout? = nil
    @State private var showEditWorkoutSheet = false
    
    @Environment(\.modelContext) private var modelContext

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
                            Toggle("Dark Mode", systemImage: "circle.lefthalf.filled", isOn: $isDarkMode)
                                .onChange(of: isDarkMode) { oldValue, newValue in
                                    let settings = UserSettings.shared
                                    settings.themeMode = newValue ? .dark : .light
                                    
                                        // Apply the theme immediately
                                    applyCurrentTheme()
                                }
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        
                        Section {
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.blue)
                                    .imageScale(.large)
                                
                                TextField("First Name", text: $name)
                                    .autocorrectionDisabled()
                                    .onChange(of: name) { oldValue, newValue in
                                        let settings = UserSettings.shared
                                        settings.firstName = newValue
                                    }
                                
                            }
                            
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        
                        Section {
                            Picker(selection: $units, label: Label("Units", systemImage: "ruler")) {
                                Text("Metric").tag(MeasurementUnit.metric)
                                Text("Imperial").tag(MeasurementUnit.imperial)
                            }
                            .pickerStyle(.menu)
                            .onChange(of: units) { oldValue, newValue in
                                let settings = UserSettings.shared
                                settings.preferredUnits = newValue
                            }
                        }
                        .listRowBackground(UltraThinView())
                        
                        
                        Section {
                            
                            Button {
                                showResetSettingsAlert = true
                            } label: {
                                Label("Reset All Settings", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .alert("Reset Settings", isPresented: $showResetSettingsAlert) {
                                Button("Cancel", role: .cancel) {}
                                Button("Reset", role: .destructive) {
                                    UserSettings.shared.resetAllSettings()
                                }
                            } message: {
                                Text("Are you sure you want to reset all settings to default values?")
                            }
                            
                            Button {
                                showDeleteDataAlert = true
                            } label: {
                                Label("Delete All Data", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .alert("Delete All Data", isPresented: $showDeleteDataAlert) {
                                Button("Cancel", role: .cancel) {}
                                Button("Delete", role: .destructive) {
                                    resetAllData()
                                }
                            } message: {
                                Text("Are you sure you want to delete all workouts (\(completedWorkouts.count))?\n\nThis will also delete custom workouts and exercizes.")
                            }
                            
                            Button {
                                showResetAllAlert = true
                            } label: {
                                Label("Reset & Delete All", systemImage: "trash")
                                    .foregroundColor(.red)
                                    .bold()
                            }
                            .alert("Reset Everything", isPresented: $showResetAllAlert) {
                                Button("Cancel", role: .cancel) {}
                                Button("Reset Everything", role: .destructive) {
                                    resetAllData()
                                    UserSettings.shared.resetAllSettings()
                                }
                            } message: {

                                Text("Are you sure you want to reset all settings and delete all data? This action cannot be undone.\n\n\(completedWorkouts.count) workouts will be deleted, including any custom workouts and exercises.")
                            }
                            
                        }
                        .listRowBackground(UltraThinView())
                        .tint(.red)
                        
                        
                        Section {
                            Button {
                                showCredits = true
                            } label: {
                                Label("Credits", systemImage: "star")
                                    .foregroundStyle(.white)
                                    .bold()
                            }

                        }
                        .listRowBackground(ColorfulView(color: $colours, speed: $speed, noise: $noise))

                        Section {
                            ForEach(completedWorkouts) { workout in
                                Button(action: {
                                    selectedWorkout = workout
                                    showEditWorkoutSheet = true
                                }) {
                                    HStack {
                                        Text(workout.name)
                                        Spacer()
                                        Text(workout.date, style: .date)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .listRowBackground(UltraThinView())
                        .sheet(isPresented: $showEditWorkoutSheet) {
                            if let workout = selectedWorkout {
                                NavigationStack {
                                    VStack {
                                        TextField("Workout Name", text: Binding(
                                            get: { workout.name },
                                            set: { workout.name = $0 }
                                        ))
                                        .textFieldStyle(.roundedBorder)

                                        TextEditor(text: Binding(
                                            get: { workout.notes },
                                            set: { workout.notes = $0 }
                                        ))
                                        .frame(height: 200)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

                                        Button("Save") {
                                            do {
                                                try modelContext.save()
                                                showEditWorkoutSheet = false
                                            } catch {
                                                print("Failed to save workout: \(error.localizedDescription)")
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                    .padding()
                                    .navigationTitle("Edit Workout")
                                }
                            }
                        }
                        
                    }
                    .scrollContentBackground(.hidden) // Make form background transparent
                }
                .sheet(isPresented: $showCredits) {
                    
                    ZStack {
                        
                        ColorfulView(color: $colours, speed: $speed, noise: $noise)
                            .opacity(0.2)
                            .ignoresSafeArea()
                        
                        NavigationStack {
                            
                            
                            Spacer()
                                .frame(height: 15)
                            
                            
                            List {
                                
                                Section {
                                    

                                    Link(destination: URL(string: "https://github.com/Lakr233/ColorfulX")!) {
                                        HStack {
                                            Text("Animated gradients")
                                                .foregroundStyle(.white)

                                            Spacer()
                                            Text("ColorfulX")
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 12)
                                    }




                                }
                                .listRowBackground(UltraThinView())
                                
                                
                                Section {
                                    Link(destination: URL(string: "https://github.com/yuhonas/free-exercise-db/tree/main?tab=readme-ov-file")!) {
                                        HStack {
                                            Text("Exercize Database (Edited)")
                                                .foregroundStyle(.white)
                                            
                                            Spacer()
                                            Text("free-exercise-db")
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                }
                                
                                .listRowBackground(UltraThinView())
                            }
                            .scrollContentBackground(.hidden) // Make form background transparent
                            .navigationTitle("Credits")
                            .toolbar {
                                Button(role: .cancel) {
                                    showCredits = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                }
                                
                            }
                        }

                        .presentationDetents([.large])
                        .presentationCornerRadius(30)
                        .presentationBackground(content: { UltraThinView() })
                    }
                    
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                }
                
            }
            .navigationTitle("Settings")
            .onAppear {
                    // Make sure the UI reflects the current settings when view appears
                isDarkMode = SettingsView.isDarkModeEnabled()
                units = SettingsView.getUnits()
                name = SettingsView.getName()
            }
        }
    }
    
        // Function to reset all SwiftData content
    private func resetAllData() {
        do {
            let fetchDescriptor = FetchDescriptor<Workout>()
            let workouts = try modelContext.fetch(fetchDescriptor)
            for workout in workouts {
                modelContext.delete(workout)
            }
            try modelContext.save()
            print("All data reset successfully.")
        } catch {
            print("Failed to delete data: \(error.localizedDescription)")
        }
    }
    
        // Apply current theme to the app
    private func applyCurrentTheme() {
            // Set the app's color scheme based on the selected theme
        DispatchQueue.main.async {
                // This is where you would typically set the app's appearance
                // In SwiftUI, this is often done at the app level with preferredColorScheme
                // But we can notify through NotificationCenter for app-wide changes
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        }
    }
    
    static func isDarkModeEnabled() -> Bool {
        let settings = UserSettings.shared
        return settings.themeMode == .dark
    }
    
    static func getUnits() -> MeasurementUnit {
        let settings = UserSettings.shared
        return settings.preferredUnits
    }
    
    static func getName() -> String {
        let settings = UserSettings.shared
        return settings.firstName
    }
    
}

#Preview {
    SettingsView()
}


struct UltraThinView: View {
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
        }
    }
}
