//
//  ContentView.swift
//  SwiftUI-VideoPlayer
//
//  Created by Bekzhan Talgat on 01.07.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var videoManager: VideoManager = .init()
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ForEach(Query.allCases, id: \.self) { query in
                        QueryTag(query: query, isSelected: videoManager.selectedQuery == query)
                            .onTapGesture {
                                videoManager.selectedQuery = query
                            }
                    }
                }
                
                ScrollView {
                    if videoManager.videos.isEmpty {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(videoManager.videos, id: \.id) { video in
                                NavigationLink {
                                    VideoView(video: video)
                                } label: {
                                    VideoCard(video: video)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.accentColor)
            .toolbar(.hidden)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
