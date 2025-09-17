import SwiftUI

//Main App Structure
@main
struct PixelHabitsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Navigation Manager
class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .title
    
    enum Screen {
        case title
        case login
        case onboarding1
        case onboarding2
        case onboarding3
        case home
    }
}

// Main Content View
struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "E8F5E9"), Color(hex: "C8E6C9")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            switch navigationManager.currentScreen {
            case .title:
                TitleScreen()
                    .environmentObject(navigationManager)
                    .transition(.opacity)
            case .login:
                LoginScreen()
                    .environmentObject(navigationManager)
                    .transition(.move(edge: .trailing))
            case .onboarding1:
                OnboardingScreen1()
                    .environmentObject(navigationManager)
                    .transition(.move(edge: .trailing))
            case .onboarding2:
                OnboardingScreen2()
                    .environmentObject(navigationManager)
                    .transition(.move(edge: .trailing))
            case .onboarding3:
                OnboardingScreen3()
                    .environmentObject(navigationManager)
                    .transition(.move(edge: .trailing))
            case .home:
                HomeScreen()
                    .environmentObject(navigationManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationManager.currentScreen)
    }
}

// Title Screen
struct TitleScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isAnimating = false
    @State private var pixelScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Pixel Logo
            ZStack {
                // Pixel heart icon
                Image("CharacterPixel")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color:Color(hex:"4CAF50").opacity(0.3),radius:0,x:3,y:3)
                    .scaleEffect(pixelScale)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: pixelScale
                    )
            }
            .onAppear {
                pixelScale = 1.1
            }
            
            // App Title
            VStack(spacing: 0) {
                PixelText("PIXEL", size: 48, color: Color(hex: "2E7D32"))
                PixelText("HABITS", size: 48, color: Color(hex: "388E3C"))
            }
            
            // Tagline
            PixelText("Track your daily wins", size: 16, color: Color(hex: "66BB6A"))
                .opacity(0.8)
            
            Spacer()
            
            // Start Button
            PixelButton(
                text: "START",
                backgroundColor: Color(hex: "4CAF50"),
                textColor: .white,
                width: 200
            ) {
                withAnimation {
                    navigationManager.currentScreen = .login
                }
            }
            
            // Version
            PixelText("v1.0", size: 12, color: Color(hex: "81C784"))
                .opacity(0.6)
                .padding(.bottom, 40)
        }
    }
}

//Login Screen
struct LoginScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                PixelButton(
                    text: "←",
                    backgroundColor: Color(hex: "66BB6A"),
                    textColor: .white,
                    width: 50
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .title
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            // profile
            Image("CharacterPixel")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            PixelText("WELCOME BACK", size: 24, color: Color(hex: "2E7D32"))
            
            // Input Fields
            VStack(spacing: 20) {
                PixelTextField(
                    placeholder: "Username",
                    text: $username,
                    icon: "👤"
                )
                
                PixelTextField(
                    placeholder: "Password",
                    text: $password,
                    icon: "🔒",
                    isSecure: true
                )
            }
            .padding(.horizontal, 40)
            
            // Error message
            if showError {
                PixelText("Please fill in all fields", size: 12, color: .red)
            }
            
            // Login Button
            PixelButton(
                text: "LOG IN",
                backgroundColor: Color(hex: "4CAF50"),
                textColor: .white,
                width: 200
            ) {
                if !username.isEmpty && !password.isEmpty {
                    withAnimation {
                        navigationManager.currentScreen = .onboarding1
                    }
                } else {
                    showError = true
                }
            }
            
            // Create Account Link
            PixelButton(
                text: "Create Account",
                backgroundColor: .clear,
                textColor: Color(hex: "66BB6A"),
                width: 200,
                outlined: true
            ) {
                // Handle create account
            }
            
            Spacer()
        }
    }
}

//Onboarding Screen 1
struct OnboardingScreen1: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress dots
            ProgressDots(currentPage: 1, totalPages: 3)
                .padding(.top, 60)
            
            Spacer()
            
            // Icon
            PixelIcon(icon: "📊", size: 100, color: Color(hex: "4CAF50"))
                .offset(y: offset)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: offset
                )
                .onAppear {
                    offset = -10
                }
            
            // Title
            PixelText("TRACK PROGRESS", size: 28, color: Color(hex: "2E7D32"))
            
            // Description
            VStack(spacing: 8) {
                PixelText("Build lasting habits with", size: 14, color: Color(hex: "66BB6A"))
                PixelText("our pixel-perfect tracker", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
            
            // Navigation
            HStack(spacing: 20) {
                PixelButton(
                    text: "Skip",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .home
                    }
                }
                
                PixelButton(
                    text: "Next →",
                    backgroundColor: Color(hex: "4CAF50"),
                    textColor: .white,
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .onboarding2
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation {
                            navigationManager.currentScreen = .onboarding2
                        }
                    }
                }
        )
    }
}

// Onboarding Screen 2
struct OnboardingScreen2: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var iconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress dots
            ProgressDots(currentPage: 2, totalPages: 3)
                .padding(.top, 60)
            
            Spacer()
            
            // Icon
            PixelIcon(icon: "🎯", size: 100, color: Color(hex: "FF9800"))
                .rotationEffect(.degrees(iconRotation))
                .animation(
                    .linear(duration: 3.0).repeatForever(autoreverses: false),
                    value: iconRotation
                )
                .onAppear {
                    iconRotation = 360
                }
            
            // Title
            PixelText("SET GOALS", size: 28, color: Color(hex: "2E7D32"))
            
            // Description
            VStack(spacing: 8) {
                PixelText("Create daily missions", size: 14, color: Color(hex: "66BB6A"))
                PixelText("and achieve your dreams", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
            
            // Navigation
            HStack(spacing: 20) {
                PixelButton(
                    text: "← Back",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .onboarding1
                    }
                }
                
                PixelButton(
                    text: "Next →",
                    backgroundColor: Color(hex: "4CAF50"),
                    textColor: .white,
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .onboarding3
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation {
                            navigationManager.currentScreen = .onboarding3
                        }
                    } else if value.translation.width > 50 {
                        withAnimation {
                            navigationManager.currentScreen = .onboarding1
                        }
                    }
                }
        )
    }
}

// Onboarding Screen 3
struct OnboardingScreen3: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var starScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress dots
            ProgressDots(currentPage: 3, totalPages: 3)
                .padding(.top, 60)
            
            Spacer()
            
            // Icon
            PixelIcon(icon: "⭐", size: 100, color: Color(hex: "FFC107"))
                .scaleEffect(starScale)
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: starScale
                )
                .onAppear {
                    starScale = 1.2
                }
            
            // Title
            PixelText("EARN REWARDS", size: 28, color: Color(hex: "2E7D32"))
            
            // Description
            VStack(spacing: 8) {
                PixelText("Unlock achievements", size: 14, color: Color(hex: "66BB6A"))
                PixelText("as you level up", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
            
            // Navigation
            HStack(spacing: 20) {
                PixelButton(
                    text: "← Back",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .onboarding2
                    }
                }
                
                PixelButton(
                    text: "Start!",
                    backgroundColor: Color(hex: "4CAF50"),
                    textColor: .white,
                    width: 100
                ) {
                    withAnimation {
                        navigationManager.currentScreen = .home
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        withAnimation {
                            navigationManager.currentScreen = .onboarding2
                        }
                    }
                }
        )
    }
}

// Home Screen
struct HomeScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedTab = 0
    @State private var habits = [
        Habit(id: 1, name: "Drink Water", icon: "💧", completed: false, streak: 5),
        Habit(id: 2, name: "Exercise", icon: "🏃", completed: false, streak: 3),
        Habit(id: 3, name: "Read Book", icon: "📚", completed: true, streak: 10),
        Habit(id: 4, name: "Meditate", icon: "🧘", completed: false, streak: 2)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PixelHeader()
            
            // Content based on selected tab
            switch selectedTab {
            case 0:
                HomeTabContent(habits: $habits)
            case 1:
                StatsScreen()
            case 2:
                AwardsScreen()
            case 3:
                ProfileScreen()
            default:
                HomeTabContent(habits: $habits)
            }
            
            // Tab Bar
            PixelTabBar(selectedTab: $selectedTab)
        }
    }
}

// Home Tab Content
struct HomeTabContent: View {
    @Binding var habits: [Habit]
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats Bar
            HStack(spacing: 30) {
                StatItem(value: "12", label: "Streak", icon: "🔥")
                StatItem(value: "85", label: "Points", icon: "⭐")
                StatItem(value: "3", label: "Level", icon: "🎮")
            }
            .padding()
            .background(Color(hex: "E8F5E9"))
            
            // Today's Habits
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PixelText("TODAY'S QUESTS", size: 18, color: Color(hex: "2E7D32"))
                        .padding(.horizontal)
                    
                    ForEach($habits) { $habit in
                        HabitRow(habit: $habit)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

//  Stats Screen
struct StatsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Weekly Progress
                VStack(alignment: .leading, spacing: 12) {
                    PixelText("WEEKLY PROGRESS", size: 18, color: Color(hex: "2E7D32"))
                    
                    HStack(spacing: 12) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Bool.random() ? Color(hex: "4CAF50") : Color(hex: "E0E0E0"))
                                    .frame(width: 40, height: 40)
                                PixelText(day, size: 12, color: Color(hex: "66BB6A"))
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                        )
                )
                
                // Statistics
                VStack(spacing: 16) {
                    PixelText("STATISTICS", size: 18, color: Color(hex: "2E7D32"))
                    
                    StatRow(icon: "📅", label: "Total Days", value: "45")
                    StatRow(icon: "✅", label: "Completed", value: "178")
                    StatRow(icon: "🎯", label: "Success Rate", value: "92%")
                    StatRow(icon: "🏆", label: "Best Streak", value: "21")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                        )
                )
            }
            .padding()
        }
        .background(Color(hex: "F5F5F5"))
    }
}

// Awards Screen
struct AwardsScreen: View {
    let achievements = [
        Achievement(icon: "🌟", title: "First Step", description: "Complete your first habit", unlocked: true),
        Achievement(icon: "🔥", title: "On Fire", description: "7 day streak", unlocked: true),
        Achievement(icon: "💪", title: "Unstoppable", description: "30 day streak", unlocked: false),
        Achievement(icon: "👑", title: "Habit King", description: "100 habits completed", unlocked: false),
        Achievement(icon: "🎯", title: "Perfect Week", description: "Complete all habits for 7 days", unlocked: true),
        Achievement(icon: "🏆", title: "Champion", description: "Reach level 10", unlocked: false)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PixelText("ACHIEVEMENTS", size: 20, color: Color(hex: "2E7D32"))
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

// MARK: - Profile Screen
struct ProfileScreen: View {
    @State private var username = "PixelMaster"
    @State private var notificationsOn = true
    @State private var soundsOn = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E8F5E9"))
                            .frame(width: 100, height: 100)
                        Text("👤")
                            .font(.system(size: 50))
                    }
                    
                    PixelText(username, size: 24, color: Color(hex: "2E7D32"))
                    PixelText("Level 3 • 85 Points", size: 14, color: Color(hex: "66BB6A"))
                }
                .padding()
                
                // Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    PixelText("SETTINGS", size: 18, color: Color(hex: "2E7D32"))
                    
                    SettingRow(icon: "🔔", title: "Notifications", isOn: $notificationsOn)
                    SettingRow(icon: "🔊", title: "Sound Effects", isOn: $soundsOn)
                    
                    Button(action: {}) {
                        HStack {
                            Text("📝")
                                .font(.system(size: 20))
                            PixelText("Edit Profile", size: 16, color: Color(hex: "4CAF50"))
                            Spacer()
                            PixelText(">", size: 16, color: Color(hex: "B0B0B0"))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                                )
                        )
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("📊")
                                .font(.system(size: 20))
                            PixelText("Data & Privacy", size: 16, color: Color(hex: "4CAF50"))
                            Spacer()
                            PixelText(">", size: 16, color: Color(hex: "B0B0B0"))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                                )
                        )
                    }
                }
                .padding()
                
                // Sign Out Button
                Button(action: {}) {
                    PixelText("Sign Out", size: 16, color: .red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

//  Custom Components

struct PixelText: View {
    let text: String
    let size: CGFloat
    let color: Color
    
    init(_ text: String, size: CGFloat = 16, color: Color = .black) {
        self.text = text
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(.custom("Courier New", size: size))
            .fontWeight(.bold)
            .foregroundColor(color)
            .shadow(color: color.opacity(0.3), radius: 0, x: 2, y: 2)
    }
}

struct PixelButton: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let width: CGFloat
    var outlined: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }) {
            Text(text)
                .font(.custom("Courier New", size: 16))
                .fontWeight(.bold)
                .foregroundColor(outlined ? backgroundColor : textColor)
                .frame(width: width, height: 50)
                .background(
                    ZStack {
                        if outlined {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(backgroundColor, lineWidth: 3)
                        } else {
                            // Shadow layer
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor.opacity(0.3))
                                .offset(x: 4, y: 4)
                            
                            // Main button
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor)
                        }
                    }
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .offset(x: isPressed ? 2 : 0, y: isPressed ? 2 : 0)
        }
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

struct PixelTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.custom("Courier New", size: 16))
                    .foregroundColor(Color(hex: "2E7D32"))
            } else {
                TextField(placeholder, text: $text)
                    .font(.custom("Courier New", size: 16))
                    .foregroundColor(Color(hex: "2E7D32"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "4CAF50"), lineWidth: 3)
                )
        )
    }
}

struct PixelIcon: View {
    let icon: String
    let size: CGFloat
    let color: Color
    
    var body: some View {
        Text(icon)
            .font(.system(size: size))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.3), radius: 0, x: 3, y: 3)
    }
}

struct ProgressDots: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...totalPages, id: \.self) { page in
                Rectangle()
                    .fill(page == currentPage ? Color(hex: "4CAF50") : Color(hex: "C8E6C9"))
                    .frame(width: page == currentPage ? 30 : 20, height: 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

struct HabitRow: View {
    @Binding var habit: Habit
    
    var body: some View {
        HStack {
            Text(habit.icon)
                .font(.system(size: 30))
            
            VStack(alignment: .leading, spacing: 4) {
                PixelText(habit.name, size: 16, color: Color(hex: "2E7D32"))
                HStack(spacing: 4) {
                    PixelText("🔥 \(habit.streak) days", size: 12, color: Color(hex: "66BB6A"))
                }
            }
            
            Spacer()
            
            Button(action: {
                habit.completed.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(habit.completed ? Color(hex: "4CAF50") : Color(hex: "C8E6C9"), lineWidth: 3)
                        .frame(width: 30, height: 30)
                    
                    if habit.completed {
                        PixelText("✓", size: 20, color: Color(hex: "4CAF50"))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                )
        )
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 24))
            PixelText(value, size: 20, color: Color(hex: "2E7D32"))
            PixelText(label, size: 12, color: Color(hex: "66BB6A"))
        }
    }
}

struct PixelHeader: View {
    var body: some View {
        HStack {
            PixelText("PIXEL HABITS", size: 20, color: Color(hex: "2E7D32"))
            Spacer()
            Text("⚙️")
                .font(.system(size: 24))
        }
        .padding()
        .background(Color(hex: "E8F5E9"))
    }
}

struct PixelTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 40) {
            TabBarItem(icon: "🏠", label: "Home", isActive: selectedTab == 0)
                .onTapGesture { selectedTab = 0 }
            TabBarItem(icon: "📊", label: "Stats", isActive: selectedTab == 1)
                .onTapGesture { selectedTab = 1 }
            TabBarItem(icon: "🏆", label: "Awards", isActive: selectedTab == 2)
                .onTapGesture { selectedTab = 2 }
            TabBarItem(icon: "👤", label: "Profile", isActive: selectedTab == 3)
                .onTapGesture { selectedTab = 3 }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                )
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 24))
            PixelText(label, size: 10, color: isActive ? Color(hex: "4CAF50") : Color(hex: "B0B0B0"))
        }
        .opacity(isActive ? 1.0 : 0.6)
    }
}

// MARK: - Models
struct Habit: Identifiable {
    let id: Int
    let name: String
    let icon: String
    var completed: Bool
    let streak: Int
}

struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let unlocked: Bool
}

// Additional Components
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.system(size: 24))
            PixelText(label, size: 14, color: Color(hex: "66BB6A"))
            Spacer()
            PixelText(value, size: 16, color: Color(hex: "2E7D32"))
        }
        .padding(.vertical, 8)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.system(size: 40))
                .opacity(achievement.unlocked ? 1.0 : 0.3)
            
            PixelText(achievement.title, size: 14, color: achievement.unlocked ? Color(hex: "2E7D32") : Color(hex: "B0B0B0"))
                .multilineTextAlignment(.center)
            
            PixelText(achievement.description, size: 10, color: Color(hex: "81C784"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(achievement.unlocked ? Color.white : Color(hex: "F5F5F5"))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(achievement.unlocked ? Color(hex: "4CAF50") : Color(hex: "E0E0E0"), lineWidth: 2)
                )
        )
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.system(size: 20))
            PixelText(title, size: 16, color: Color(hex: "2E7D32"))
            Spacer()
            
            // Custom Toggle
            Button(action: {
                isOn.toggle()
            }) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isOn ? Color(hex: "4CAF50") : Color(hex: "E0E0E0"))
                    .frame(width: 50, height: 28)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: isOn ? 11 : -11)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 2)
                )
        )
    }
}

//  - Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
