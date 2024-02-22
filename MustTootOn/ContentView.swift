//
//  ContentView.swift
//  MustTootOn
//
//  Created by Willy Breitenbach on 04.11.22.
//

import SwiftUI
import NukeUI

struct ContentView: View {
    @StateObject
    private var viewModel: ViewModel = ViewModel()    

    var body: some View {
        VStack {

            List(viewModel.instances) { instance in
                Button {
                    viewModel.start(domain: instance.domain)
                } label: {
                    HStack {
                        LazyImage(url: URL(string: instance.proxiedThumbnail))
                            .frame(width: 50, height: 50)
                            .mask(RoundedRectangle(cornerRadius: 5, style: .continuous))

                        VStack(alignment: .leading) {
                            Text(instance.domain)
                                .font(.headline)
                            Text("Users: \(instance.totalUsers)")
                                .font(.subheadline)
                        }

                        Spacer()
                    }
                    .foregroundStyle(.foreground)
                }
            }
        }
        .task {
            try? await viewModel.fetchServers()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
