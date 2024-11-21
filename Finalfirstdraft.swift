

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
import Charts

struct StockDashboardView: View {
    @State private var selectedStock: Stock? = nil
    @State private var showDetailView = false
    @State private var sentiment: MarketSentiment = .neutral
    @State private var showPortfolioOverview = true

    var body: some View {
        ZStack {
            // Dynamic Background Theme
            MarketSentimentBackground(sentiment: sentiment)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header: Portfolio Overview and Sentiment
                if showPortfolioOverview {
                    PortfolioOverviewView(sentiment: $sentiment, toggleOverview: {
                        withAnimation { showPortfolioOverview.toggle() }
                    })
                        .padding(.bottom, 10)
                }

                // Watchlist Section
                WatchlistSection(selectedStock: $selectedStock, showDetailView: $showDetailView)

                // Trends and Insights
                TrendsAndInsightsSection(stocks: stockSampleData)

                // News Section
                LatestNewsSection()

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showDetailView) {
                if let stock = selectedStock {
                    StockDetailView(stock: stock)
                }
            }
        }
    }
}

// MARK: - PortfolioOverviewView

struct PortfolioOverviewView: View {
    @Binding var sentiment: MarketSentiment
    let toggleOverview: () -> Void

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Portfolio")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Sentiment: \(sentiment.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(sentiment.color)
                }
                Spacer()
                Button(action: toggleOverview) {
                    Image(systemName: "chevron.up.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(Angle(degrees: showPortfolioOverview ? 0 : 180))
                }
            }
            .padding()
            .background(BlurView(style: .systemUltraThinMaterialDark))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}

// MARK: - TrendsAndInsightsSection

struct TrendsAndInsightsSection: View {
    let stocks: [Stock]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Trends and Insights")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(stocks) { stock in
                        InteractiveChart(stock: stock)
                            .frame(width: 300, height: 200)
                            .background(BlurView(style: .systemThinMaterialDark))
                            .cornerRadius(15)
                    }
                }
            }
        }
    }
}

// MARK: - StockDetailView

struct StockDetailView: View {
    let stock: Stock

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text(stock.companyName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

            // Dynamic Chart
            LineChart(data: stock.sparkline, color: stock.change > 0 ? .green : .red)
                .frame(height: 200)
                .padding()

            // Stock Details
            VStack(alignment: .leading, spacing: 10) {
                StockDetailRow(title: "Price", value: "\(stock.price, specifier: "%.2f")")
                StockDetailRow(title: "Change", value: "\(stock.change > 0 ? "+" : "")\(stock.change, specifier: "%.2f")", valueColor: stock.change > 0 ? .green : .red)
                StockDetailRow(title: "52W High", value: "\(stock.high52W, specifier: "%.2f")")
                StockDetailRow(title: "52W Low", value: "\(stock.low52W, specifier: "%.2f")")
            }
            .padding()
            .background(BlurView(style: .systemThinMaterialDark))
            .cornerRadius(15)

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct StockDetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Dynamic Market Sentiment Background

struct MarketSentimentBackground: View {
    let sentiment: MarketSentiment

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: sentiment.colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Supporting Models and Sample Data

enum MarketSentiment: String {
    case bullish
    case bearish
    case neutral

    var colors: [Color] {
        switch self {
        case .bullish: return [Color.green.opacity(0.7), Color.black]
        case .bearish: return [Color.red.opacity(0.7), Color.black]
        case .neutral: return [Color.gray.opacity(0.7), Color.black]
        }
    }

    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        }
    }
}

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let companyName: String
    let price: Double
    let change: Double
    let high52W: Double
    let low52W: Double
    let sparkline: [Double]
}

let stockSampleData = [
    Stock(symbol: "AAPL", companyName: "Apple Inc.", price: 150.00, change: +2.50, high52W: 180.00, low52W: 120.00, sparkline: [120, 130, 150, 140, 160]),
    Stock(symbol: "NVDA", companyName: "NVIDIA Corp.", price: 144.10, change: -1.79, high52W: 200.00, low52W: 100.00, sparkline: [100, 120, 140, 130, 144])
]
import SwiftUI
import AVKit

struct TVDashboardView: View {
    @State private var selectedCategory: String = "Apple TV+"
    @State private var selectedContent: MediaItem? = nil
    @State private var showDetailView = false

    var body: some View {
        NavigationView {
            HStack {
                // Sidebar Navigation
                SidebarView(selectedCategory: $selectedCategory)

                // Main Content Area
                VStack(spacing: 20) {
                    // Dynamic Featured Carousel
                    DynamicFeaturedCarouselView(selectedContent: $selectedContent, showDetailView: $showDetailView)

                    // "Your Journey" Section
                    YourJourneySection()

                    // Personalized Recommendations
                    PersonalizedRecommendationsView()

                    // Trending Content Section
                    TrendingNowView()

                    Spacer()
                }
                .padding()
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            .sheet(isPresented: $showDetailView) {
                if let content = selectedContent {
                    MediaDetailView(mediaItem: content)
                }
            }
        }
    }
}

// MARK: - DynamicFeaturedCarouselView

struct DynamicFeaturedCarouselView: View {
    @Binding var selectedContent: MediaItem?
    @Binding var showDetailView: Bool

    var body: some View {
        TabView {
            ForEach(featuredMediaItems) { item in
                ZStack {
                    // Cinematic Background
                    AsyncImage(url: item.backgroundURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 30)
                            .overlay(Color.black.opacity(0.3))
                            .transition(.scale)
                    } placeholder: {
                        Color.black
                    }
                    .frame(height: 300)
                    .clipped()

                    // Content Details and Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer()
                        Text(item.title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        HStack {
                            Button(action: {
                                selectedContent = item
                                showDetailView = true
                            }) {
                                Text("Watch Now")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            Button(action: {
                                // Add to Watchlist
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
    }
}

// MARK: - YourJourneySection

struct YourJourneySection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Journey")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(yourJourneyItems) { item in
                        MediaThumbnailView(mediaItem: item)
                    }
                }
            }
        }
    }
}

// MARK: - TrendingNowView

struct TrendingNowView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trending Now")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(trendingMediaItems) { item in
                        InteractiveMediaCard(mediaItem: item)
                    }
                }
            }
        }
    }
}

// MARK: - InteractiveMediaCard

struct InteractiveMediaCard: View {
    let mediaItem: MediaItem

    @State private var showOverlay = false

    var body: some View {
        ZStack {
            AsyncImage(url: mediaItem.thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 100)
                    .cornerRadius(10)
            } placeholder: {
                Color.gray
                    .frame(width: 150, height: 100)
                    .cornerRadius(10)
            }

            if showOverlay {
                VStack {
                    Text(mediaItem.title)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                    Text("Rating: \(mediaItem.rating)/10")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Button(action: {
                        // Add to Watchlist Action
                    }) {
                        Text("Add to Watchlist")
                            .font(.caption2)
                            .padding(5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .frame(width: 150, height: 100)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .onTapGesture {
                    showOverlay.toggle()
                }
            }
        }
        .onTapGesture {
            showOverlay.toggle()
        }
    }
}

// MARK: - Sample Data Models

struct MediaItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let thumbnailURL: URL
    let backgroundURL: URL
    let rating: Double
}

let featuredMediaItems = [
    MediaItem(title: "Bad Sisters", description: "A gripping drama about secrets and family.", thumbnailURL: URL(string: "https://example.com/bad-sisters-thumbnail.jpg")!, backgroundURL: URL(string: "https://example.com/bad-sisters-background.jpg")!, rating: 8.7),
    MediaItem(title: "Presumed Innocent", description: "A legal thriller full of twists and turns.", thumbnailURL: URL(string: "https://example.com/presumed-thumbnail.jpg")!, backgroundURL: URL(string: "https://example.com/presumed-background.jpg")!, rating: 8.2)
]
