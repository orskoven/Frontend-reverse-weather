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
