//
//  ContentView.swift
//  SearchableTutorial
//
//  Created by Victor Roldan on 8/08/22.
//

import SwiftUI

struct CountriesModel : Codable{
    let name : String
    let code : String
    
    static func loadJson() -> [CountriesModel]?{
        guard let url = Bundle.main.url(forResource: "Countries", withExtension: "json") else{ return nil }
        do{
            let data = try Data(contentsOf: url)
            let countries = try JSONDecoder().decode([CountriesModel].self, from: data)
            return countries
        }catch{
            return nil
        }
    }
}

class ViewModel : ObservableObject{
    @Published var countries = [CountriesModel]()
    
    init(){
        countries = CountriesModel.loadJson() ?? []
    }
}

private func flag(country:String) -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var searchText : String = ""
    
    var results : [CountriesModel]{
        if searchText.isEmpty{
            return viewModel.countries
        }else{
            return viewModel.countries.filter{$0.name.uppercased().contains(searchText.uppercased())}
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List{
                    ForEach(results, id: \.code) { countries in
                        HStack {
                            Text(flag(country:countries.code))
                                .font(.system(size: 30))
                            Text(countries.name)
                        }
                    }
                }.listStyle(.plain)
            }
            .navigationTitle("Paises")
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Text("Escribe el nombre de un pais"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
