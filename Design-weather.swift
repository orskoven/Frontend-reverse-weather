import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherDashboardView()
        }
    }
}

// MARK: - WeatherDashboardView

struct WeatherDashboardView: View {
    @State private var selectedLocation: String = "Copenhagen"
    @State private var isExpanded = false
    @State private var showSettings = false
    @State private var skyAnimationPhase = 0.0

    var body: some View {
        ZStack {
            // Dynamic Sky Background
            SkyAnimationView(weatherCondition: "Clear", phase: $skyAnimationPhase)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Personalized Greeting and Dynamic Narration
                PersonalizedGreetingView()
                    .padding(.top, 20)
                    .accessibilityLabel("Personalized greeting based on your time and weather conditions.")

                // Header with Animated Weather Transition
                HeaderView(location: selectedLocation, temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                    .padding(.bottom, 20)

                // Interactive Weather Highlights
                InteractiveHighlightsView()
                    .padding()
                    .background(BlurView(style: .systemUltraThinMaterialDark))
                    .cornerRadius(20)
                    .shadow(radius: 5)

                // Hourly Forecast
                HourlyForecastView(hourlyData: hourlySampleData)

                // Expandable Daily Forecast
                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData, onDaySelect: { _ in })
                        .transition(.opacity)
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData.prefix(3).map { $0 }) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }

                Spacer()

                // Quick Navigation Buttons
                HStack {
                    NavigationButton(title: "Settings", systemImage: "gearshape.fill") {
                        showSettings.toggle()
                    }
                    NavigationButton(title: "Weekly Overview", systemImage: "calendar") {
                        // Navigate to the weekly overview
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                    skyAnimationPhase += 1
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - InteractiveHighlightsView

struct InteractiveHighlightsView: View {
    var body: some View {
        HStack(spacing: 20) {
            InteractiveHighlightCard(
                title: "Rainfall",
                value: "0 mm",
                detail: "No rain expected today. Enjoy clear skies!",
                icon: "cloud.drizzle.fill"
            )
            InteractiveHighlightCard(
                title: "UV Index",
                value: "3",
                detail: "Moderate UV index. Sunscreen recommended if outdoors.",
                icon: "sun.max.fill"
            )
            InteractiveHighlightCard(
                title: "Wind",
                value: "5 m/s",
                detail: "Gentle breeze today, great for outdoor activities.",
                icon: "wind"
            )
        }
        .accessibilityElement(children: .combine)
    }
}

struct InteractiveHighlightCard: View {
    let title: String
    let value: String
    let detail: String
    let icon: String
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(10)
        .shadow(radius: 3)
        .onTapGesture {
            showDetail.toggle()
        }
        .popover(isPresented: $showDetail) {
            VStack {
                Text(detail)
                    .font(.body)
                    .padding()
                Button("Close") {
                    showDetail = false
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

// MARK: - NavigationButton

struct NavigationButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(BlurView(style: .systemThinMaterialDark))
            .cornerRadius(10)
        }
        .foregroundColor(.white)
    }
}

// MARK: - SkyAnimationView

struct SkyAnimationView: View {
    let weatherCondition: String
    @Binding var phase: Double

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: weatherConditionGradient(for: weatherCondition)),
                startPoint: .top,
                endPoint: .bottom
            )

            // Floating Clouds
            CloudsView(phase: phase)
        }
    }

    private func weatherConditionGradient(for condition: String) -> [Color] {
        switch condition {
        case "Partly Cloudy": return [Color.blue.opacity(0.7), Color.gray.opacity(0.4)]
        case "Rain": return [Color.gray, Color.blue.opacity(0.3)]
        case "Clear": return [Color.orange, Color.blue]
        default: return [Color.black, Color.gray.opacity(0.5)]
        }
    }
}

// MARK: - CloudsView

struct CloudsView: View {
    var phase: Double

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5) { index in
                Image(systemName: "cloud.fill")
                    .resizable()
                    .frame(width: 150, height: 100)
                    .foregroundColor(.white.opacity(0.5))
                    .position(
                        x: CGFloat(phase * 50 + Double(index) * 100).truncatingRemainder(dividingBy: geometry.size.width),
                        y: CGFloat(index) * 60 + 100
                    )
            }
        }
    }
}
import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherDashboardView()
        }
    }
}

// MARK: - WeatherDashboardView

struct WeatherDashboardView: View {
    @State private var selectedLocation: String = "Copenhagen"
    @State private var isExpanded = false
    @State private var showSettings = false
    @State private var skyAnimationPhase = 0.0 // Used for dynamic sky animations

    var body: some View {
        ZStack {
            // Dynamic Sky Background
            SkyAnimationView(weatherCondition: "Partly Cloudy", phase: $skyAnimationPhase)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header with Greeting and Location
                PersonalizedGreetingView()
                    .padding(.top, 10)

                HeaderView(location: selectedLocation, temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                    .padding(.bottom, 20)

                // Interactive Weather Summary Cards
                WeatherDetailsView()
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(15)

                // Expandable Hourly Forecast
                HourlyForecastView(hourlyData: hourlySampleData)

                // Expandable Daily Forecast
                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData, onDaySelect: { day in
                        print("Selected Day: \(day.day)")
                    })
                        .transition(.opacity)
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData.prefix(3).map { $0 }) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }

                Spacer()

                // Footer with Settings
                HStack {
                    Button(action: { showSettings.toggle() }) {
                        Label("Settings", systemImage: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
            }
            .padding()
            .onAppear {
                withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                    skyAnimationPhase += 1
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - SkyAnimationView

struct SkyAnimationView: View {
    let weatherCondition: String
    @Binding var phase: Double

    var body: some View {
        let colors: [Color] = {
            switch weatherCondition {
            case "Partly Cloudy": return [Color.blue.opacity(0.7), Color.gray.opacity(0.4)]
            case "Rainy": return [Color.gray, Color.blue.opacity(0.3)]
            case "Clear": return [Color.orange, Color.blue]
            default: return [Color.black, Color.gray.opacity(0.5)]
            }
        }()

        return ZStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
            CloudsView(phase: phase) // Floating cloud animations
        }
    }
}

struct CloudsView: View {
    var phase: Double

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5) { index in
                Image(systemName: "cloud.fill")
                    .resizable()
                    .frame(width: 150, height: 100)
                    .foregroundColor(.white.opacity(0.5))
                    .position(
                        x: CGFloat(phase * 50 + Double(index) * 100).truncatingRemainder(dividingBy: geometry.size.width),
                        y: CGFloat(index) * 60 + 100
                    )
                    .offset(y: -30)
            }
        }
    }
}

// MARK: - WeatherDetailsView with Tap Interaction

struct WeatherDetailsView: View {
    @State private var showDetail = false
    @State private var selectedDetail: String?

    var body: some View {
        HStack(spacing: 20) {
            WeatherDetailCard(title: "Feels Like", value: "0°", icon: "thermometer") {
                selectedDetail = "Feels Like temperature gives you a sense of actual warmth."
                showDetail = true
            }
            WeatherDetailCard(title: "Humidity", value: "85%", icon: "drop.fill") {
                selectedDetail = "Humidity is high today. Stay hydrated!"
                showDetail = true
            }
            WeatherDetailCard(title: "UV Index", value: "2", icon: "sun.max.fill") {
                selectedDetail = "UV Index is low. No sunscreen required."
                showDetail = true
            }
        }
        .sheet(isPresented: $showDetail) {
            if let detail = selectedDetail {
                WeatherDetailExpandedView(detail: detail)
            }
        }
    }
}

struct WeatherDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}

struct WeatherDetailExpandedView: View {
    let detail: String

    var body: some View {
        VStack {
            Text("Detail")
                .font(.headline)
            Text(detail)
                .font(.body)
                .padding()
        }
        .padding()
    }
}

// MARK: - OnboardingView for First-Time Users

struct OnboardingView: View {
    @State private var showDashboard = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Welcome to WeatherPro!")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Your personalized weather app awaits.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                withAnimation {
                    showDashboard = true
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .background(SkyAnimationView(weatherCondition: "Clear", phase: .constant(0.0)))
        .fullScreenCover(isPresented: $showDashboard) {
            WeatherDashboardView()
        }
    }
}

import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView() // Starts with onboarding for a seamless first-time experience
        }
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @State private var showDashboard = false
    
    var body: some View {
        ZStack {
            WeatherGradientView(condition: "Clear") // A dynamic, friendly gradient
            VStack(spacing: 30) {
                Text("Welcome to WeatherPro")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Text("Your personalized weather experience awaits.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showDashboard = true
                    }
                }) {
                    Text("Get Started")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            }
            .padding()
        }
        .transition(.opacity)
        .fullScreenCover(isPresented: $showDashboard) {
            TabView {
                WeatherDashboardView()
                    .tabItem { Label("Dashboard", systemImage: "cloud.sun.fill") }
                FavoritesView()
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
        }
    }
}

// MARK: - WeatherDashboardView

struct WeatherDashboardView: View {
    @State private var selectedLocation: String = "Copenhagen"
    @State private var isExpanded = false
    @State private var showWeatherStories = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Personalized Greeting
                PersonalizedGreetingView()
                
                // Header with dynamic animations
                HeaderView(location: selectedLocation, temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                    .padding(.top, 10)
                    .background(WeatherGradientView(condition: "Partly Cloudy"))

                // Weather Stories Section
                if showWeatherStories {
                    WeatherStoriesView()
                        .padding()
                        .transition(.slide)
                }
                
                // Real-Time Weather Details
                WeatherDetailsView()
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(15)

                // Expandable Hourly and Daily Forecasts
                HourlyForecastView(hourlyData: hourlySampleData)
                
                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData, onDaySelect: { _ in })
                        .transition(.opacity)
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData.prefix(3).map { $0 }) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }

                // Swipeable Map Section
                WeatherMapView()
                    .frame(height: 250)
                    .cornerRadius(15)
            }
            .padding()
        }
        .background(
            WeatherGradientView(condition: "Partly Cloudy")
        )
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    if value.translation.width < 0 {
                        selectedLocation = "Stockholm" // Example swipe-to-switch
                    } else if value.translation.width > 0 {
                        selectedLocation = "Berlin"
                    }
                }
        )
        .animation(.easeInOut, value: selectedLocation)
    }
}

// MARK: - PersonalizedGreetingView

struct PersonalizedGreetingView: View {
    var body: some View {
        let greeting: String = {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 5..<12: return "Good Morning!"
            case 12..<18: return "Good Afternoon!"
            case 18..<22: return "Good Evening!"
            default: return "Good Night!"
            }
        }()
        
        return Text(greeting)
            .font(.title)
            .bold()
            .foregroundColor(.white)
            .padding()
    }
}

// MARK: - WeatherStoriesView

struct WeatherStoriesView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                WeatherStoryCard(title: "Today", imageName: "sun.max.fill", content: "Clear skies expected for most of the day.")
                WeatherStoryCard(title: "Tomorrow", imageName: "cloud.rain.fill", content: "Rainy conditions in the evening.")
                WeatherStoryCard(title: "Weekend", imageName: "snow", content: "Snowfall likely as temperatures drop.")
            }
        }
    }
}

struct WeatherStoryCard: View {
    let title: String
    let imageName: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            Text(content)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(width: 200)
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - WeatherGradientView

struct WeatherGradientView: View {
    let condition: String
    
    var body: some View {
        let gradientColors: [Color] = {
            switch condition {
            case "Partly Cloudy": return [Color.blue.opacity(0.6), Color.gray.opacity(0.4)]
            case "Rain": return [Color.blue.opacity(0.7), Color.gray.opacity(0.8)]
            case "Clear": return [Color.orange, Color.blue]
            default: return [Color.gray, Color.blue.opacity(0.3)]
            }
        }()
        
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Weather Map View with Animations

struct WeatherMapView: View {
    @State private var showTimelapse = false

    var body: some View {
        VStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683),
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            )))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { showTimelapse.toggle() }
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                )
        }
    }
}import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                WeatherDashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "cloud.sun.fill")
                    }
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .accentColor(.blue)
        }
    }
}

// MARK: - WeatherDashboardView

struct WeatherDashboardView: View {
    @State private var selectedLocation: String = "Copenhagen"
    @State private var isExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Dynamic Header with Weather Animations
                HeaderView(location: selectedLocation, temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                    .padding(.top, 20)
                    .background(WeatherGradientView(condition: "Partly Cloudy"))
                
                // Real-Time Weather Details
                WeatherDetailsView()
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(15)
                    .shadow(radius: 5)

                // Expandable Hourly Forecast
                HourlyForecastView(hourlyData: hourlySampleData)
                
                // Daily Forecast with Expand/Collapse
                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData, onDaySelect: { _ in })
                        .transition(.opacity)
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData.prefix(3).map { $0 }) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
                
                // Radar Map Section
                WeatherMapView()
                    .frame(height: 250)
                    .cornerRadius(15)
                    .padding(.vertical)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarHidden(true)
    }
}

// MARK: - FavoritesView

struct FavoritesView: View {
    @State private var favoriteLocations = ["Copenhagen", "Stockholm", "Berlin"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteLocations, id: \.self) { location in
                    HStack {
                        Text(location)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

// MARK: - WeatherGradientView

struct WeatherGradientView: View {
    let condition: String
    
    var body: some View {
        let gradientColors: [Color] = {
            switch condition {
            case "Partly Cloudy":
                return [Color.blue.opacity(0.5), Color.gray.opacity(0.3)]
            case "Rain":
                return [Color.gray.opacity(0.8), Color.blue.opacity(0.5)]
            case "Clear":
                return [Color.orange.opacity(0.7), Color.blue.opacity(0.5)]
            default:
                return [Color.black, Color.blue.opacity(0.3)]
            }
        }()
        
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - BlurView

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - WeatherDetailsView

struct WeatherDetailsView: View {
    var body: some View {
        HStack(spacing: 20) {
            WeatherDetailCard(title: "Feels Like", value: "0°", icon: "thermometer")
            WeatherDetailCard(title: "Humidity", value: "85%", icon: "drop.fill")
            WeatherDetailCard(title: "UV Index", value: "2", icon: "sun.max.fill")
            WeatherDetailCard(title: "Sunrise", value: "07:59 AM", icon: "sunrise.fill")
        }
    }
}

struct WeatherDetailCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @State private var isMetric = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Toggle("Metric Units", isOn: $isMetric)
                }
                Section(header: Text("Theme")) {
                    Text("Coming Soon")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherHomeView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - WeatherHomeView

struct WeatherHomeView: View {
    @State private var showSettings = false
    @State private var showAlerts = false
    @State private var showSearch = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Section
                HeaderView(location: "KØBENHAVN Ø", temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                
                // Alerts Button
                if showAlerts {
                    WeatherAlertsView()
                        .transition(.opacity)
                        .padding(.vertical)
                }

                Button(action: { withAnimation { showAlerts.toggle() } }) {
                    Text(showAlerts ? "Hide Weather Alerts" : "Show Weather Alerts")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                
                // Hourly Forecast
                HourlyForecastView(hourlyData: hourlySampleData)
                
                // Expandable Daily Forecast
                DailyForecastSummaryView(dailyData: dailySampleData) {
                    // Placeholder for expanding view or detail action
                }
                
                // Interactive Radar Map
                WeatherMapView()
                    .frame(height: 250)
                    .cornerRadius(15)
                    .padding(.vertical)

                // Historical Data Chart
                HistoricalDataView()

                // Settings Button
                Button(action: { showSettings.toggle() }) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }

                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.black]), startPoint: .top, endPoint: .bottom))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - WeatherAlertsView

struct WeatherAlertsView: View {
    let alerts = [
        "Heavy Rainfall Expected Tomorrow",
        "Strong Winds Advisory: 50km/h",
        "Cold Wave Warning: Temperatures Below -5°"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weather Alerts")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(alerts, id: \.self) { alert in
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text(alert)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.red.opacity(0.8))
        .cornerRadius(10)
    }
}

// MARK: - HistoricalDataView

struct HistoricalDataView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Historical Data")
                .font(.headline)
                .foregroundColor(.white)
            
            LineChartView(data: [10, 20, 15, 25, 30, 18], title: "Last Week Temps (°C)")
                .frame(height: 150)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
        }
    }
}

// MARK: - LineChartView (Reusable)

struct LineChartView: View {
    let data: [Double]
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 5)
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let maxValue = data.max() ?? 1
                    let scale = height / CGFloat(maxValue)
                    
                    for (index, value) in data.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(data.count - 1)
                        let y = height - (CGFloat(value) * scale)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
            }
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @State private var isMetric = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Toggle(isOn: $isMetric) {
                        Text("Use Metric Units")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Searchable Location View

struct SearchableLocationsView: View {
    @State private var searchQuery = ""
    let locations = ["Copenhagen", "Stockholm", "Berlin", "London", "Paris"]
    @State private var filteredLocations: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Locations", text: $searchQuery)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .onChange(of: searchQuery) { query in
                        filteredLocations = locations.filter { $0.lowercased().contains(query.lowercased()) }
                    }

                List(filteredLocations.isEmpty ? locations : filteredLocations, id: \.self) { location in
                    Text(location)
                        .foregroundColor(.white)
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.black)
            .navigationTitle("Search")
        }
    }
}

// MARK: - Additional Sample Data

let hourlySampleData = [
    HourlyForecast(time: "19", icon: "cloud.fill", temperature: 1),
    HourlyForecast(time: "20", icon: "cloud.moon.fill", temperature: 0),
    HourlyForecast(time: "21", icon: "cloud.fill", temperature: -1),
    HourlyForecast(time: "22", icon: "cloud.fill", temperature: -1)
]

let dailySampleData = [
    DailyForecast(day: "Thursday", condition: "Cloudy", high: 3, low: -1),
    DailyForecast(day: "Friday", condition: "Rain", high: 3, low: -1),
    DailyForecast(day: "Saturday", condition: "Clear", high: 5, low: -1),
    DailyForecast(day: "Sunday", condition: "Rain", high: 4, low: 2),
    DailyForecast(day: "Monday", condition: "Rain", high: 9, low: 6)
]

// MARK: - Models

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temperature: Int
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let condition: String
    let high: Int
    let low: Int
}import SwiftUI
import MapKit

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherHomeView()
                .preferredColorScheme(.dark) // Support for Dark Mode
        }
    }
}

// MARK: - WeatherHomeView

struct WeatherHomeView: View {
    @State private var isExpanded = false
    @State private var selectedDay: DailyForecast? = nil
    @State private var showMap = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView(location: "KØBENHAVN Ø", temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                HourlyForecastView(hourlyData: hourlySampleData)
                
                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData) { day in
                        self.selectedDay = day
                        self.isExpanded = false
                    }
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData) {
                        self.isExpanded = true
                    }
                }
                
                WeatherDetailsView()
                
                if showMap {
                    WeatherMapView()
                        .frame(height: 200)
                        .transition(.slide)
                        .padding(.vertical)
                }
                
                Button(action: { showMap.toggle() }) {
                    Text(showMap ? "Hide Weather Map" : "Show Weather Map")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.black]), startPoint: .top, endPoint: .bottom))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - DailyForecastSummaryView

struct DailyForecastSummaryView: View {
    let dailyData: [DailyForecast]
    let onExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Next 3 Days")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onExpand) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(dailyData.prefix(3)) { data in
                HStack {
                    Text(data.day)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(data.high)° / \(data.low)°")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - WeatherMapView

struct WeatherMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    )

    var body: some View {
        Map(coordinateRegion: $region)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Precipitation Map")
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            )
            .cornerRadius(10)
    }
}

// MARK: - Improved DailyForecastView

struct DailyForecastView: View {
    let dailyData: [DailyForecast]
    let onDaySelect: (DailyForecast) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("10-Day Forecast")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(dailyData) { data in
                Button(action: { onDaySelect(data) }) {
                    HStack {
                        Text(data.day)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 8) {
                            Text(data.condition)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("H: \(data.high)°")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("L: \(data.low)°")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - WeatherDetailsView (with Accessibility)

struct WeatherDetailsView: View {
    var body: some View {
        HStack(spacing: 20) {
            WeatherDetailCard(title: "Air Quality", value: "Fair", accessibilityLabel: "Air quality is fair")
            WeatherDetailCard(title: "Wind", value: "2 m/s", accessibilityLabel: "Wind speed is 2 meters per second")
            WeatherDetailCard(title: "Pressure", value: "989 hPa", accessibilityLabel: "Pressure is 989 hectopascals")
        }
    }
}

// MARK: - WeatherDetailCard

struct WeatherDetailCard: View {
    let title: String
    let value: String
    let accessibilityLabel: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .accessibilityLabel(accessibilityLabel)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Sample Data

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temperature: Int
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let condition: String
    let high: Int
    let low: Int
}

let hourlySampleData = [
    HourlyForecast(time: "19", icon: "cloud.fill", temperature: 1),
    HourlyForecast(time: "20", icon: "cloud.moon.fill", temperature: 0),
    HourlyForecast(time: "21", icon: "cloud.fill", temperature: -1),
    HourlyForecast(time: "22", icon: "cloud.fill", temperature: -1)
]

let dailySampleData = [
    DailyForecast(day: "Thursday", condition: "Cloudy", high: 3, low: -1),
    DailyForecast(day: "Friday", condition: "Rain", high: 3, low: -1),
    DailyForecast(day: "Saturday", condition: "Clear", high: 5, low: -1),
    DailyForecast(day: "Sunday", condition: "Rain", high: 4, low: 2),
    DailyForecast(day: "Monday", condition: "Rain", high: 9, low: 6)
]import SwiftUI

// MARK: - WeatherApp

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherHomeView()
        }
    }
}

// MARK: - WeatherHomeView

struct WeatherHomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView(location: "KØBENHAVN Ø", temperature: "1°", condition: "Partly Cloudy", high: "3°", low: "-1°")
                HourlyForecastView(hourlyData: hourlySampleData)
                DailyForecastView(dailyData: dailySampleData)
                WeatherDetailsView()
                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.black]), startPoint: .top, endPoint: .bottom))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - HeaderView

struct HeaderView: View {
    let location: String
    let temperature: String
    let condition: String
    let high: String
    let low: String

    var body: some View {
        VStack(spacing: 5) {
            Text(location)
                .font(.headline)
                .foregroundColor(.white)
            Text(temperature)
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(.white)
            Text(condition)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text("H: \(high)  L: \(low)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - HourlyForecastView

struct HourlyForecastView: View {
    let hourlyData: [HourlyForecast]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(hourlyData) { data in
                    VStack(spacing: 5) {
                        Text(data.time)
                            .font(.caption)
                            .foregroundColor(.white)
                        Image(systemName: data.icon)
                            .renderingMode(.original)
                            .font(.headline)
                        Text("\(data.temperature)°")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - DailyForecastView

struct DailyForecastView: View {
    let dailyData: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("10-Day Forecast")
                .font(.headline)
                .foregroundColor(.white)
            ForEach(dailyData) { data in
                HStack {
                    Text(data.day)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 8) {
                        Text(data.condition)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("H: \(data.high)°")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("L: \(data.low)°")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - WeatherDetailsView

struct WeatherDetailsView: View {
    var body: some View {
        HStack(spacing: 20) {
            WeatherDetailCard(title: "Air Quality", value: "Fair")
            WeatherDetailCard(title: "Wind", value: "2 m/s")
            WeatherDetailCard(title: "Pressure", value: "989 hPa")
        }
    }
}

// MARK: - WeatherDetailCard

struct WeatherDetailCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Sample Data

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temperature: Int
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let condition: String
    let high: Int
    let low: Int
}

let hourlySampleData = [
    HourlyForecast(time: "19", icon: "cloud.fill", temperature: 1),
    HourlyForecast(time: "20", icon: "cloud.moon.fill", temperature: 0),
    HourlyForecast(time: "21", icon: "cloud.fill", temperature: -1),
    HourlyForecast(time: "22", icon: "cloud.fill", temperature: -1)
]

let dailySampleData = [
    DailyForecast(day: "Thursday", condition: "Cloudy", high: 3, low: -1),
    DailyForecast(day: "Friday", condition: "Rain", high: 3, low: -1),
    DailyForecast(day: "Saturday", condition: "Clear", high: 5, low: -1)
]
