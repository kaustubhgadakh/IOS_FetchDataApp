//
//  ContentView.swift
//  FetchDataApp
//
//  Created by Kaustubh Kishor Gadakh on 19/06/24.
//

import SwiftUI

struct GitHubUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}


struct ContentView: View {
    @State var user: GitHubUser?

    var body: some View {
        List {
            HStack(spacing:20){
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                .frame(width: 50, height: 60)

                VStack(alignment: .leading) {
                    Text(user?.login ?? "username" )
                        .font(.title3)
                        .bold()

                    Text(user?.bio ?? "Bio")
                }
            }
            .task {
                do{
                    user = try await getUser()
                }catch GHError.invalidURL{
                    print("invalid URL")
                }catch GHError.invalidResponse{
                    print("invalid Response")
                }catch GHError.invalidData{
                    print("invalid Data")
                }catch{
                    print("unexpected error")
                }
        }
        }
    }

    func getUser() async throws -> GitHubUser{
        let endpoint = "http://api.github.com/users"
        guard let url = URL(string: endpoint) else{
            throw GHError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw GHError.invalidResponse
        }

        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }catch{
            throw GHError.invalidData
        }

    }
}

#Preview {
    ContentView()
}
