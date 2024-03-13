//
//  TextRecommendationView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 05.03.2024.
//

import SwiftUI

struct DataSet: Codable, Identifiable {
    let id = UUID()
    let name: String
    let text: String
}

struct TextRecommendationView: View {
    @ObservedObject var vm: AppViewModel
    @State var name = ""
    var body: some View {
        ScrollView {
            VStack {
                TextField("Enter name of the product", text: $name)
                HStack {
                    Button(action: {
                        loadAndPrintJSONContents()
                    }) {
                        Text("Load Data")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: {
                        deleteJSONFileContents()
                    }) {
                        Text("Delete")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: {
                        deleteDataserJSON()
                    }) {
                        Text("Delete Whole Json")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: {
                        addToDataset()
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            Text(vm.text)
        }
        .padding()
    }
    
    private func addToDataset() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("dataset.json")
        
        do {
            // Read existing data from the file (if it exists)
            var existingDatasets: [DataSet] = []
            if fileManager.fileExists(atPath: fileURL.path) {
                let existingData = try Data(contentsOf: fileURL)
                existingDatasets = try JSONDecoder().decode([DataSet].self, from: existingData)
                
                // Print the existing data
                for dataset in existingDatasets {
                    print("ID: \(dataset.id), Text: \(dataset.name ?? "")")
                }
            }
            
            // Create a new DataSet object with the entered text
            let newDataset = DataSet(name: name, text: vm.text.lowercased())
            
            // Append the new DataSet to the existing array
            existingDatasets.append(newDataset)
            
            // Convert the updated array to JSON data
            let updatedData = try JSONEncoder().encode(existingDatasets)
            
            // Write the updated data to the file
            try updatedData.write(to: fileURL)
            
            // Clear the text field after successful save
        } catch {
            print("Error handling JSON data: \(error)")
        }
    }
    
    func loadAndPrintJSONContents() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("dataset.json")
        
        do {
            // Read existing data from the file (if it exists)
            var existingDatasets: [DataSet] = []
            if fileManager.fileExists(atPath: fileURL.path) {
                let existingData = try Data(contentsOf: fileURL)
                existingDatasets = try JSONDecoder().decode([DataSet].self, from: existingData)
                
                print("\nDEBUG: Load")
                // Print the existing data
                for dataset in existingDatasets {
                    let test = String(dataset.text.filter { !"\n\t\r".contains($0) })
                    print("{")
                    print("{")
                    print("\"text\": \"\(test.lowercased())\",")
                    print("\"label\": []")
                    print("}")
                }
            }
        } catch {
            print("Error handling JSON data: \(error)")
        }
    }
    
    private func deleteJSONFileContents() {
        do {
            guard let fileURL = Bundle.main.url(forResource: "dataset", withExtension: "json") else {
                print("JSON file not found")
                return
            }
            
            let newDataset = DataSet(name: name, text: vm.text)
            let updatedData = try JSONEncoder().encode(newDataset)
            
            do {
                try updatedData.write(to: fileURL)
            } catch {
                print("Error deleting JSON file contents: \(error)")
            }
        } catch {
            print("Error handling JSON data: \(error)")
        }
    }
    
    func deleteDataserJSON() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Cannot access document directory")
            return
        }
        
        let fileURL = documentDirectory.appendingPathComponent("dataset.json")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("dataser.json deleted successfully")
        } catch {
            print("Error deleting dataser.json: \(error)")
        }
    }
}

#Preview {
    TextRecommendationView(vm: AppViewModel())
}
