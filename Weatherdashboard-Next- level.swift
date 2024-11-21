

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
import Charts

struct StockDashboardView: View {
    @State private var selectedStock: Stock? = nil
    @State private var showDetailView = false
    @State private var sentiment: MarketSentiment = .neutral // Dynamic theme
    @State private var isNewsVisible = true // Toggle news visibility

    var body: some View {
        ZStack {
            // Dynamic Background Theme
            MarketSentimentBackground(sentiment: sentiment)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header Section with Sentiment Summary
                HeaderSection(sentiment: $sentiment)

                // Watchlist with Interactive Cards
                WatchlistSection(selectedStock: $selectedStock, showDetailView: $showDetailView)

                // Expandable Trends Chart
                TrendsChartSection(stocks: stockSampleData)

                // Toggleable News Section
                if isNewsVisible {
                    LatestNewsSection(toggleNews: { withAnimation { isNewsVisible.toggle() } })
                }

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

// MARK: - Header Section

struct HeaderSection: View {
    @Binding var sentiment: MarketSentiment

    var body: some View {
        VStack(spacing: 10) {
            Text("Market Overview")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

            // Sentiment Indicator
            Text(sentiment.rawValue.uppercased())
                .font(.headline)
                .foregroundColor(sentiment.color)
        }
    }
}

// MARK: - Watchlist Section

struct WatchlistSection: View {
    @Binding var selectedStock: Stock?
    @Binding var showDetailView: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Watchlist")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(stockSampleData) { stock in
                        StockCardView(stock: stock)
                            .onTapGesture {
                                withAnimation {
                                    selectedStock = stock
                                    showDetailView = true
                                }
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Trends Chart Section

struct TrendsChartSection: View {
    let stocks: [Stock]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Trends")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)

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

// MARK: - Latest News Section

struct LatestNewsSection: View {
    let toggleNews: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Latest News")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: toggleNews) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            ForEach(newsSampleData) { news in
                VStack(alignment: .leading, spacing: 5) {
                    Text(news.title)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    Text(news.source)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 5)
                Divider().background(Color.white.opacity(0.2))
            }
        }
    }
}

// MARK: - Interactive Chart

struct InteractiveChart: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading) {
            Text(stock.symbol)
                .font(.headline)
                .foregroundColor(.white)

            GeometryReader { geometry in
                Path { path in
                    let data = stock.sparkline
                    guard data.count > 1 else { return }
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(data.count - 1)
                    let maxY = data.max() ?? 1
                    let scale = height / CGFloat(maxY)

                    for index in data.indices {
                        let x = CGFloat(index) * stepX
                        let y = height - CGFloat(data[index]) * scale
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(stock.change > 0 ? Color.green : Color.red, lineWidth: 2)
            }
        }
    }
}

// MARK: - Market Sentiment Background

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

enum MarketSentiment: String {
    case bullish
    case bearish
    case neutral

    var colors: [Color] {
        switch self {
        case .bullish: return [Color.green.opacity(0.8), Color.black]
        case .bearish: return [Color.red.opacity(0.8), Color.black]
        case .neutral: return [Color.gray.opacity(0.8), Color.black]
        }
    }

    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        }
    }
}import SwiftUI
import Charts

struct StockDashboardView: View {
    @State private var selectedStock: Stock? = nil
    @State private var showDetailView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Personalized Watchlist Header
                Text("Your Watchlist")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                // Live Stock Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(stockSampleData) { stock in
                            StockCardView(stock: stock)
                                .onTapGesture {
                                    withAnimation {
                                        selectedStock = stock
                                        showDetailView.toggle()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                // Sparkline Summary Section
                SparklineSummaryView(stocks: stockSampleData)
                    .padding()

                // Latest News Section
                LatestStockNewsView()
                    .padding()

                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $showDetailView) {
                if let stock = selectedStock {
                    StockDetailView(stock: stock)
                }
            }
        }
    }
}

// MARK: - StockCardView

struct StockCardView: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stock.symbol)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Text(stock.change > 0 ? "+\(stock.change, specifier: "%.2f")" : "\(stock.change, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(stock.change > 0 ? .green : .red)
            }
            Spacer()
            Text(stock.price, format: .number)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(stock.companyName)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(width: 200, height: 120)
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - SparklineSummaryView

struct SparklineSummaryView: View {
    let stocks: [Stock]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Market Trends")
                .font(.headline)
                .foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(stocks) { stock in
                        VStack {
                            Text(stock.symbol)
                                .font(.caption)
                                .foregroundColor(.white)
                            LineChart(data: stock.sparkline, color: stock.change > 0 ? .green : .red)
                                .frame(width: 100, height: 50)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - LineChart Component

struct LineChart: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard data.count > 1 else { return }
                let stepX = geometry.size.width / CGFloat(data.count - 1)
                let maxY = data.max() ?? 1
                let scale = geometry.size.height / CGFloat(maxY)
                for index in data.indices {
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height - CGFloat(data[index]) * scale
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, lineWidth: 2)
        }
    }
}

// MARK: - LatestStockNewsView

struct LatestStockNewsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Latest News")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(newsSampleData) { news in
                VStack(alignment: .leading) {
                    Text(news.title)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    Text(news.source)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 5)
                Divider().background(Color.white.opacity(0.2))
            }
        }
    }
}

// MARK: - StockDetailView

struct StockDetailView: View {
    let stock: Stock

    var body: some View {
        VStack(spacing: 20) {
            Text(stock.companyName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            LineChart(data: stock.sparkline, color: stock.change > 0 ? .green : .red)
                .frame(height: 200)
                .padding()
            VStack(alignment: .leading, spacing: 10) {
                Text("Details:")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Price: \(stock.price, format: .number)")
                    .font(.body)
                    .foregroundColor(.white)
                Text("Change: \(stock.change > 0 ? "+" : "")\(stock.change, specifier: "%.2f")")
                    .foregroundColor(stock.change > 0 ? .green : .red)
                Text("52W High: \(stock.high52W, format: .number)")
                    .foregroundColor(.white)
                Text("52W Low: \(stock.low52W, format: .number)")
                    .foregroundColor(.white)
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
Take a moment to self reflect and breath deeply Great job take another moment to self critique the design even further and extend immersive experience for users being able to feel a seemless connection flow between them and the data and expand the design code to even going more above and beyond enhancing the user experience in immersive SwiftUI code 
// MARK: - Sample Data Models

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

struct News: Identifiable {
    let id = UUID()
    let title: String
    let source: String
}

let stockSampleData = [
    Stock(symbol: "AAPL", companyName: "Apple Inc.", price: 228.82, change: -0.18, high52W: 250.0, low52W: 210.0, sparkline: [220, 225, 228, 230, 229]),
    Stock(symbol: "NVDA", companyName: "NVIDIA Corp.", price: 144.10, change: -1.79, high52W: 180.0, low52W: 120.0, sparkline: [140, 142, 145, 144, 143])
]

let newsSampleData = [
    News(title: "NVIDIA's earnings fall short of expectations", source: "Yahoo Finance"),
    News(title: "Apple reaches all-time high", source: "Bloomberg"),
    News(title: "Tech stocks struggle amid rising rates", source: "CNBC")
]

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
    @State private var skyAnimationPhase = 0.0
    @State private var showWeeklyPlanner = false
    @State private var showSummaryPopover = false

    var body: some View {
        ZStack {
            // Dynamic Sky Background
            SkyAnimationView(weatherCondition: "Rainy", phase: $skyAnimationPhase)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Greeting and Daily Summary
                PersonalizedGreetingView()
                    .padding(.top, 20)

                WeatherSummaryCard(onTap: {
                    showSummaryPopover.toggle()
                })
                    .padding(.bottom, 10)
                    .popover(isPresented: $showSummaryPopover) {
                        WeatherNarrativeView(summary: "Light rain expected this afternoon. Ideal for cozy indoor activities!")
                    }

                // Animated Current Weather Header
                HeaderView(location: selectedLocation, temperature: "12°", condition: "Rainy", high: "15°", low: "8°")
                    .padding(.bottom, 20)

                // Real-Time Interactive Highlights
                InteractiveHighlightsView()

                // Expandable Hourly and Daily Forecast
                HourlyForecastView(hourlyData: hourlySampleData)
                    .padding(.top)

                if isExpanded {
                    DailyForecastView(dailyData: dailySampleData, onDaySelect: { _ in })
                        .transition(.opacity)
                } else {
                    DailyForecastSummaryView(dailyData: dailySampleData.prefix(3).map { $0 }) {
                        withAnimation { isExpanded.toggle() }
                    }
                }

                Spacer()

                // Planner and Navigation Buttons
                HStack {
                    NavigationButton(title: "Weekly Planner", systemImage: "calendar") {
                        showWeeklyPlanner.toggle()
                    }
                    .sheet(isPresented: $showWeeklyPlanner) {
                        WeeklyPlannerView()
                    }

                    Spacer()

                    NavigationButton(title: "Settings", systemImage: "gearshape.fill") {
                        // Open settings view
                    }
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
    }
}

// MARK: - WeatherSummaryCard

struct WeatherSummaryCard: View {
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today’s Outlook")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Light rain this afternoon, clearing by evening.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .padding()
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - WeatherNarrativeView

struct WeatherNarrativeView: View {
    let summary: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Detailed Summary")
                .font(.headline)
                .foregroundColor(.white)

            Text(summary)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {}
                .foregroundColor(.blue)
        }
        .padding()
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(15)
        .padding()
    }
}

// MARK: - WeeklyPlannerView

struct WeeklyPlannerView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Weekly Planner")
                .font(.largeTitle)
                .bold()

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(weeklyPlannerSampleData) { day in
                        WeeklyPlannerCard(day: day)
                    }
                }
            }
        }
        .padding()
    }
}

struct WeeklyPlannerCard: View {
    let day: WeeklyPlannerDay

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(day.day)
                    .font(.headline)
                Text(day.summary)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(day.high)° / \(day.low)°")
                .font(.headline)
        }
        .padding()
        .background(BlurView(style: .systemUltraThinMaterial))
        .cornerRadius(10)
    }
}

// MARK: - Models for Weekly Planner

struct WeeklyPlannerDay: Identifiable {
    let id = UUID()
    let day: String
    let summary: String
    let high: Int
    let low: Int
}

let weeklyPlannerSampleData = [
    WeeklyPlannerDay(day: "Monday", summary: "Sunny with mild winds", high: 18, low: 10),
    WeeklyPlannerDay(day: "Tuesday", summary: "Cloudy with light rain", high: 15, low: 8),
    WeeklyPlannerDay(day: "Wednesday", summary: "Heavy rainfall expected", high: 12, low: 6),
    WeeklyPlannerDay(day: "Thursday", summary: "Clear skies and sunny", high: 20, low: 11)
]

// MARK: - SkyAnimationView and CloudsView (Unchanged for Reusability)
// (Same as previous iteration)

