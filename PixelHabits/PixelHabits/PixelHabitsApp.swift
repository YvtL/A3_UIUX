import SwiftUI
import AVFoundation

// MARK: - Main App Structure
@main
struct PixelHabitsApp: App {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var hapticManager = HapticManager.shared
   
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(hapticManager)
                .onAppear {
                    audioManager.playBackgroundMusic("menu_bgm")
                }
        }
    }
}

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    static let shared = AudioManager()
   
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
   
    @Published var isMuted = false
    @Published var musicVolume: Float = 0.7 {
        didSet {
            backgroundMusicPlayer?.volume = musicVolume
        }
    }
    @Published var effectsVolume: Float = 1.0
   
    init() {
        setupAudioSession()
        preloadSounds()
    }
   
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
   
    private func preloadSounds() {
        let soundEffects = [
            "button_tap", "success", "level_up", "coin_collect",
            "page_turn", "error", "notification", "achievement_unlock"
        ]
       
        for sound in soundEffects {
            if let path = Bundle.main.path(forResource: sound, ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = effectsVolume
                    soundEffectPlayers[sound] = player
                    print("✓ Loaded sound: \(sound)")
                } catch {
                    print("✗ Failed to load sound \(sound): \(error.localizedDescription)")
                }
            } else {
                print("✗ Could not find sound file: \(sound).mp3")
            }
        }
    }
   
    func playBackgroundMusic(_ filename: String) {
        guard !isMuted else { return }
        
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop forever
                backgroundMusicPlayer?.volume = musicVolume
                backgroundMusicPlayer?.play()
                print("✓ Playing background music: \(filename)")
            } catch {
                print("✗ Failed to play background music \(filename): \(error.localizedDescription)")
            }
        } else {
            print("✗ Could not find music file: \(filename).mp3")
        }
    }
   
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
   
    func playSoundEffect(_ name: String) {
        guard !isMuted else { return }
        
        if let player = soundEffectPlayers[name] {
            player.currentTime = 0 // Reset to beginning
            player.volume = effectsVolume
            player.play()
            print("✓ Playing sound: \(name)")
        } else {
            print("✗ Sound not found: \(name)")
        }
    }
   
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            backgroundMusicPlayer?.pause()
        } else {
            backgroundMusicPlayer?.play()
        }
    }
}

// MARK: - Haptic Manager
class HapticManager: ObservableObject {
    static let shared = HapticManager()
   
    @Published var isEnabled = true
   
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
   
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
   
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Navigation Manager
class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .splash
    @Published var previousScreen: Screen = .splash
   
    enum Screen {
        case splash
        case title
        case login
        case onboarding1
        case onboarding2
        case onboarding3
        case home
        case settings
    }
   
    func navigate(to screen: Screen) {
        previousScreen = currentScreen
        currentScreen = screen
    }
   
    func goBack() {
        currentScreen = previousScreen
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
   
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8F5E9"), Color(hex: "C8E6C9")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
           
            Group {
                switch navigationManager.currentScreen {
                case .splash:
                    SplashScreen()
                        .environmentObject(navigationManager)
                        .transition(.opacity)
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
                case .settings:
                    SettingsScreen()
                        .environmentObject(navigationManager)
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationManager.currentScreen)
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var progressValue: CGFloat = 0
   
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
           
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "4CAF50").opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 20)
               
                Image("CharacterPixel")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
            }
           
            VStack(spacing: 8) {
                PixelText("PIXEL HABITS", size: 36, color: Color(hex: "2E7D32"))
                    .opacity(logoOpacity)
               
                PixelText("Level Up Your Life", size: 16, color: Color(hex: "66BB6A"))
                    .opacity(logoOpacity * 0.8)
            }
           
            Spacer()
           
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "E0E0E0"))
                        .frame(width: 200, height: 8)
                   
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "4CAF50"))
                        .frame(width: 200 * progressValue, height: 8)
                }
               
                PixelText("Loading...", size: 12, color: Color(hex: "81C784"))
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
           
            withAnimation(.linear(duration: 2.0)) {
                progressValue = 1.0
            }
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                audioManager.playSoundEffect("page_turn")
                navigationManager.navigate(to: .title)
            }
        }
    }
}

// MARK: - Title Screen
struct TitleScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var isAnimating = false
    @State private var pixelScale: CGFloat = 1.0
    @State private var starPositions: [(CGFloat, CGFloat)] = []
   
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(Color.yellow.opacity(0.3))
                    .scaleEffect(CGFloat.random(in: 0.3...0.7))
                    .position(
                        x: starPositions.isEmpty ? 0 : starPositions[index % starPositions.count].0,
                        y: starPositions.isEmpty ? 0 : starPositions[index % starPositions.count].1
                    )
                    .animation(
                        .linear(duration: Double.random(in: 20...40))
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
           
            VStack(spacing: 40) {
                Spacer()
               
                ZStack {
                    Image("CharacterPixel")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .shadow(color:Color(hex:"4CAF50").opacity(0.3),radius:0,x:3,y:3)
                        .scaleEffect(pixelScale)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        pixelScale = 1.1
                    }
                }
               
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(Array("PIXEL".enumerated()), id: \.offset) { index, character in
                            Text(String(character))
                                .font(.custom("Courier New", size: 48))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "2E7D32"))
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .opacity(isAnimating ? 1.0 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.05),
                                    value: isAnimating
                                )
                        }
                    }
                    HStack(spacing: 0) {
                        ForEach(Array("HABITS".enumerated()), id: \.offset) { index, character in
                            Text(String(character))
                                .font(.custom("Courier New", size: 48))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "388E3C"))
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .opacity(isAnimating ? 1.0 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(index + 5) * 0.05),
                                    value: isAnimating
                                )
                        }
                    }
                }
               
                PixelText("Track your daily wins", size: 16, color: Color(hex: "66BB6A"))
                    .opacity(isAnimating ? 0.8 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.7), value: isAnimating)
               
                Spacer()
               
                VStack(spacing: 16) {
                    PixelButton(
                        text: "START",
                        backgroundColor: Color(hex: "4CAF50"),
                        textColor: .white,
                        width: 200
                    ) {
                        hapticManager.impact(.medium)
                        audioManager.playSoundEffect("button_tap")
                        withAnimation {
                            navigationManager.currentScreen = .login
                        }
                    }
                   
                    HStack(spacing: 20) {
                        IconButton(systemName: "gearshape.fill", color: Color(hex: "757575")) {
                            hapticManager.selection()
                            audioManager.playSoundEffect("button_tap")
                            navigationManager.navigate(to: .settings)
                        }
                       
                        IconButton(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                                  color: Color(hex: "9C27B0")) {
                            hapticManager.selection()
                            audioManager.playSoundEffect("button_tap")
                            audioManager.toggleMute()
                        }
                    }
                }
               
                PixelText("v1.0", size: 12, color: Color(hex: "81C784"))
                    .opacity(0.6)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            generateStarPositions()
            isAnimating = true
            audioManager.playBackgroundMusic("menu_bgm")
        }
    }
   
    func generateStarPositions() {
        starPositions = (0..<15).map { _ in
            (CGFloat.random(in: 0...UIScreen.main.bounds.width),
             CGFloat.random(in: 0...UIScreen.main.bounds.height))
        }
    }
}

// MARK: - Login Screen
struct LoginScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var isLoading = false
   
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                PixelButton(
                    text: "←",
                    backgroundColor: Color(hex: "66BB6A"),
                    textColor: .white,
                    width: 50
                ) {
                    hapticManager.impact(.light)
                    audioManager.playSoundEffect("button_tap")
                    withAnimation {
                        navigationManager.currentScreen = .title
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 50)
           
            ZStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    Image("CharacterPixel")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
            }
           
            PixelText("WELCOME BACK", size: 24, color: Color(hex: "2E7D32"))
           
            VStack(spacing: 20) {
                PixelTextField(
                    placeholder: "Username",
                    text: $username,
                    icon: "👤"
                )
                .onChange(of: username) { _ in
                    hapticManager.selection()
                }
               
                PixelTextField(
                    placeholder: "Password",
                    text: $password,
                    icon: "🔒",
                    isSecure: true
                )
                .onChange(of: password) { _ in
                    hapticManager.selection()
                }
            }
            .padding(.horizontal, 40)
           
            if showError {
                PixelText("Please fill in all fields", size: 12, color: .red)
                    .transition(.scale)
            }
           
            PixelButton(
                text: isLoading ? "LOADING..." : "LOG IN",
                backgroundColor: Color(hex: "4CAF50"),
                textColor: .white,
                width: 200
            ) {
                if !username.isEmpty && !password.isEmpty {
                    hapticManager.notification(.success)
                    audioManager.playSoundEffect("success")
                    isLoading = true
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            navigationManager.currentScreen = .onboarding1
                        }
                    }
                } else {
                    hapticManager.notification(.error)
                    audioManager.playSoundEffect("error")
                    showError = true
                }
            }
            .disabled(isLoading)
           
            PixelButton(
                text: "Create Account",
                backgroundColor: .clear,
                textColor: Color(hex: "66BB6A"),
                width: 200,
                outlined: true
            ) {
                hapticManager.impact(.light)
                audioManager.playSoundEffect("button_tap")
            }
           
            Spacer()
        }
    }
}

// MARK: - Onboarding Screens
struct OnboardingScreen1: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var offset: CGFloat = 0
   
    var body: some View {
        VStack(spacing: 30) {
            ProgressDots(currentPage: 1, totalPages: 3)
                .padding(.top, 60)
           
            Spacer()
           
            PixelIcon(icon: "📊", size: 100, color: Color(hex: "4CAF50"))
                .offset(y: offset)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: offset
                )
                .onAppear {
                    offset = -10
                    audioManager.playSoundEffect("page_turn")
                }
           
            PixelText("TRACK PROGRESS", size: 28, color: Color(hex: "2E7D32"))
           
            VStack(spacing: 8) {
                PixelText("Build lasting habits with", size: 14, color: Color(hex: "66BB6A"))
                PixelText("our pixel-perfect tracker", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
           
            Spacer()
           
            HStack(spacing: 20) {
                PixelButton(
                    text: "Skip",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    hapticManager.impact(.light)
                    audioManager.playSoundEffect("button_tap")
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
                    hapticManager.impact(.medium)
                    audioManager.playSoundEffect("button_tap")
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
                        hapticManager.selection()
                        audioManager.playSoundEffect("page_turn")
                        withAnimation {
                            navigationManager.currentScreen = .onboarding2
                        }
                    }
                }
        )
    }
}

struct OnboardingScreen2: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var iconRotation: Double = 0
   
    var body: some View {
        VStack(spacing: 30) {
            ProgressDots(currentPage: 2, totalPages: 3)
                .padding(.top, 60)
           
            Spacer()
           
            PixelIcon(icon: "🎯", size: 100, color: Color(hex: "FF9800"))
                .rotationEffect(.degrees(iconRotation))
                .animation(
                    .linear(duration: 3.0).repeatForever(autoreverses: false),
                    value: iconRotation
                )
                .onAppear {
                    iconRotation = 360
                    audioManager.playSoundEffect("page_turn")
                }
           
            PixelText("SET GOALS", size: 28, color: Color(hex: "2E7D32"))
           
            VStack(spacing: 8) {
                PixelText("Create daily missions", size: 14, color: Color(hex: "66BB6A"))
                PixelText("and achieve your dreams", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
           
            Spacer()
           
            HStack(spacing: 20) {
                PixelButton(
                    text: "← Back",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    hapticManager.impact(.light)
                    audioManager.playSoundEffect("button_tap")
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
                    hapticManager.impact(.medium)
                    audioManager.playSoundEffect("button_tap")
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
                        hapticManager.selection()
                        audioManager.playSoundEffect("page_turn")
                        withAnimation {
                            navigationManager.currentScreen = .onboarding3
                        }
                    } else if value.translation.width > 50 {
                        hapticManager.selection()
                        audioManager.playSoundEffect("page_turn")
                        withAnimation {
                            navigationManager.currentScreen = .onboarding1
                        }
                    }
                }
        )
    }
}

struct OnboardingScreen3: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var starScale: CGFloat = 1.0
   
    var body: some View {
        VStack(spacing: 30) {
            ProgressDots(currentPage: 3, totalPages: 3)
                .padding(.top, 60)
           
            Spacer()
           
            PixelIcon(icon: "⭐", size: 100, color: Color(hex: "FFC107"))
                .scaleEffect(starScale)
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: starScale
                )
                .onAppear {
                    starScale = 1.2
                    audioManager.playSoundEffect("page_turn")
                }
           
            PixelText("EARN REWARDS", size: 28, color: Color(hex: "2E7D32"))
           
            VStack(spacing: 8) {
                PixelText("Unlock achievements", size: 14, color: Color(hex: "66BB6A"))
                PixelText("as you level up", size: 14, color: Color(hex: "66BB6A"))
            }
            .multilineTextAlignment(.center)
           
            Spacer()
           
            HStack(spacing: 20) {
                PixelButton(
                    text: "← Back",
                    backgroundColor: .clear,
                    textColor: Color(hex: "81C784"),
                    width: 100
                ) {
                    hapticManager.impact(.light)
                    audioManager.playSoundEffect("button_tap")
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
                    hapticManager.notification(.success)
                    audioManager.playSoundEffect("success")
                    audioManager.playBackgroundMusic("main_bgm")
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
                        hapticManager.selection()
                        audioManager.playSoundEffect("page_turn")
                        withAnimation {
                            navigationManager.currentScreen = .onboarding2
                        }
                    }
                }
        )
    }
}

// MARK: - Home Screen
struct HomeScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var selectedTab = 0
    @State private var habits = [
        Habit(id: 1, name: "Drink Water", icon: "💧", completed: false, streak: 5, xp: 10),
        Habit(id: 2, name: "Exercise", icon: "🏃", completed: false, streak: 3, xp: 20),
        Habit(id: 3, name: "Read Book", icon: "📚", completed: true, streak: 10, xp: 15),
        Habit(id: 4, name: "Meditate", icon: "🧘", completed: false, streak: 2, xp: 25)
    ]
    @State private var userLevel = 3
    @State private var userXP = 245
    @State private var showLevelUp = false
   
    var body: some View {
        VStack(spacing: 0) {
            EnhancedPixelHeader(level: userLevel, xp: userXP) {
                hapticManager.selection()
                audioManager.playSoundEffect("button_tap")
                navigationManager.navigate(to: .settings)
            }
           
            switch selectedTab {
            case 0:
                EnhancedHomeTabContent(habits: $habits) { habit, completed in
                    handleHabitCompletion(habit: habit, completed: completed)
                }
            case 1:
                StatsScreen()
            case 2:
                AwardsScreen()
            case 3:
                ProfileScreen()
            default:
                EnhancedHomeTabContent(habits: $habits) { habit, completed in
                    handleHabitCompletion(habit: habit, completed: completed)
                }
            }
           
            EnhancedPixelTabBar(selectedTab: $selectedTab) { tab in
                hapticManager.selection()
                audioManager.playSoundEffect("button_tap")
            }
        }
        .overlay(
            LevelUpAnimationView(isShowing: $showLevelUp, newLevel: userLevel)
        )
    }
   
    func handleHabitCompletion(habit: Habit, completed: Bool) {
        if completed {
            hapticManager.notification(.success)
            audioManager.playSoundEffect("success")
            userXP += habit.xp
           
            if userXP >= 500 {
                levelUp()
            }
        } else {
            hapticManager.impact(.light)
            audioManager.playSoundEffect("button_tap")
        }
    }
   
    func levelUp() {
        userLevel += 1
        userXP = 0
        showLevelUp = true
        hapticManager.notification(.success)
        audioManager.playSoundEffect("level_up")
    }
}

// MARK: - Enhanced Components
struct EnhancedHomeTabContent: View {
    @Binding var habits: [Habit]
    let onHabitToggle: (Habit, Bool) -> Void
   
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 30) {
                StatItem(value: "12", label: "Streak", icon: "🔥")
                StatItem(value: "85", label: "Points", icon: "⭐")
                StatItem(value: "3", label: "Level", icon: "🎮")
            }
            .padding()
            .background(Color(hex: "E8F5E9"))
           
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PixelText("TODAY'S QUESTS", size: 18, color: Color(hex: "2E7D32"))
                        .padding(.horizontal)
                   
                    ForEach($habits) { $habit in
                        EnhancedHabitRow(habit: $habit) { completed in
                            onHabitToggle(habit, completed)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct EnhancedHabitRow: View {
    @Binding var habit: Habit
    let onToggle: (Bool) -> Void
    @State private var showXPAnimation = false
   
    var body: some View {
        HStack {
            Text(habit.icon)
                .font(.system(size: 30))
           
            VStack(alignment: .leading, spacing: 4) {
                PixelText(habit.name, size: 16, color: Color(hex: "2E7D32"))
                HStack(spacing: 8) {
                    PixelText("🔥 \(habit.streak) days", size: 12, color: Color(hex: "66BB6A"))
                    PixelText("⚡ +\(habit.xp) XP", size: 12, color: Color(hex: "FFC107"))
                }
            }
           
            Spacer()
           
            Button(action: {
                habit.completed.toggle()
                onToggle(habit.completed)
                if habit.completed {
                    showXPAnimation = true
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(habit.completed ? Color(hex: "4CAF50") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(habit.completed ? Color(hex: "4CAF50") : Color(hex: "C8E6C9"), lineWidth: 3)
                        )
                        .frame(width: 30, height: 30)
                   
                    if habit.completed {
                        PixelText("✓", size: 20, color: .white)
                    }
                }
            }
            .overlay(
                Text("+\(habit.xp) XP")
                    .font(.custom("Courier New", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "FFC107"))
                    .opacity(showXPAnimation ? 0 : 1)
                    .offset(y: showXPAnimation ? -30 : 0)
                    .animation(.easeOut(duration: 1.0), value: showXPAnimation)
                    .onChange(of: showXPAnimation) { _ in
                        if showXPAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showXPAnimation = false
                            }
                        }
                    }
            )
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

struct EnhancedPixelHeader: View {
    let level: Int
    let xp: Int
    let onMenuTap: () -> Void
   
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    PixelText("PIXEL HABITS", size: 20, color: Color(hex: "2E7D32"))
                    HStack(spacing: 8) {
                        Label("Level \(level)", systemImage: "star.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "FFC107"))
                       
                        Text("• \(xp) XP")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "66BB6A"))
                    }
                }
                Spacer()
                Button(action: onMenuTap) {
                    Text("⚙️")
                        .font(.system(size: 24))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
           
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "E8F5E9"))
                        .frame(height: 4)
                   
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "FFC107"))
                        .frame(width: geometry.size.width * (CGFloat(xp) / 500.0), height: 4)
                        .animation(.spring(), value: xp)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(hex: "E8F5E9"))
    }
}

struct EnhancedPixelTabBar: View {
    @Binding var selectedTab: Int
    let onTabSelected: (Int) -> Void
   
    var body: some View {
        HStack(spacing: 40) {
            TabBarItem(icon: "🏠", label: "Home", isActive: selectedTab == 0)
                .onTapGesture {
                    selectedTab = 0
                    onTabSelected(0)
                }
            TabBarItem(icon: "📊", label: "Stats", isActive: selectedTab == 1)
                .onTapGesture {
                    selectedTab = 1
                    onTabSelected(1)
                }
            TabBarItem(icon: "🏆", label: "Awards", isActive: selectedTab == 2)
                .onTapGesture {
                    selectedTab = 2
                    onTabSelected(2)
                }
            TabBarItem(icon: "👤", label: "Profile", isActive: selectedTab == 3)
                .onTapGesture {
                    selectedTab = 3
                    onTabSelected(3)
                }
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

struct LevelUpAnimationView: View {
    @Binding var isShowing: Bool
    let newLevel: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
   
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
               
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(scale)
                   
                    PixelText("LEVEL UP!", size: 36, color: Color(hex: "FFC107"))
                        .scaleEffect(scale)
                   
                    PixelText("You reached Level \(newLevel)", size: 20, color: .white)
                        .opacity(opacity)
                }
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                    withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                        opacity = 1.0
                    }
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

struct IconButton: View {
    let systemName: String
    let color: Color
    let action: () -> Void
   
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: color.opacity(0.3), radius: 5)
        }
    }
}

// MARK: - Settings Screen
struct SettingsScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    @State private var notificationsOn = true
   
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                PixelButton(
                    text: "← Back",
                    backgroundColor: .clear,
                    textColor: Color(hex: "4CAF50"),
                    width: 100
                ) {
                    navigationManager.goBack()
                }
                Spacer()
                PixelText("SETTINGS", size: 20, color: Color(hex: "2E7D32"))
                Spacer()
                Color.clear.frame(width: 100)
            }
            .padding()
            .background(Color.white)
           
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        PixelText("AUDIO", size: 16, color: Color(hex: "757575"))
                       
                        VStack(spacing: 0) {
                            HStack {
                                Text("🎵")
                                    .font(.system(size: 20))
                                PixelText("Music Volume", size: 14, color: Color(hex: "2E7D32"))
                                Spacer()
                                Slider(value: $audioManager.musicVolume, in: 0...1)
                                    .frame(width: 100)
                                    .accentColor(Color(hex: "4CAF50"))
                            }
                            .padding()
                           
                            Divider()
                           
                            HStack {
                                Text("🔊")
                                    .font(.system(size: 20))
                                PixelText("Sound Effects", size: 14, color: Color(hex: "2E7D32"))
                                Spacer()
                                Slider(value: $audioManager.effectsVolume, in: 0...1)
                                    .frame(width: 100)
                                    .accentColor(Color(hex: "4CAF50"))
                            }
                            .padding()
                           
                            Divider()
                           
                            HStack {
                                Text("🔇")
                                    .font(.system(size: 20))
                                PixelText("Mute All", size: 14, color: Color(hex: "2E7D32"))
                                Spacer()
                                Toggle("", isOn: $audioManager.isMuted)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4CAF50")))
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                   
                    VStack(alignment: .leading, spacing: 16) {
                        PixelText("HAPTICS", size: 16, color: Color(hex: "757575"))
                       
                        HStack {
                            Text("📳")
                                .font(.system(size: 20))
                            PixelText("Haptic Feedback", size: 14, color: Color(hex: "2E7D32"))
                            Spacer()
                            Toggle("", isOn: $hapticManager.isEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4CAF50")))
                                .onChange(of: hapticManager.isEnabled) { _ in
                                    hapticManager.impact(.medium)
                                }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                   
                    VStack(alignment: .leading, spacing: 16) {
                        PixelText("NOTIFICATIONS", size: 16, color: Color(hex: "757575"))
                       
                        HStack {
                            Text("🔔")
                                .font(.system(size: 20))
                            PixelText("Daily Reminders", size: 14, color: Color(hex: "2E7D32"))
                            Spacer()
                            Toggle("", isOn: $notificationsOn)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4CAF50")))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

// MARK: - Reusable Components
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
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor.opacity(0.3))
                                .offset(x: 4, y: 4)
                           
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

// MARK: - Additional Screens
struct StatsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

struct ProfileScreen: View {
    @State private var username = "PixelMaster"
    @State private var notificationsOn = true
    @State private var soundsOn = true
   
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                }
                .padding()
               
                Spacer(minLength: 40)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

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

// MARK: - Models
struct Habit: Identifiable {
    let id: Int
    let name: String
    let icon: String
    var completed: Bool
    let streak: Int
    let xp: Int
}

struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let unlocked: Bool
}

// MARK: - Extensions
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
