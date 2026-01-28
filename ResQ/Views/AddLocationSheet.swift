//
//  AddLocationSheet.swift
//  ResQ
//
//  Created by sym on 2026/01/20.
//
import SwiftUI
import CoreLocation

struct AddLocationSheet: View {
    @Environment(\.dismiss) private var dismiss

    let coordinate: CLLocationCoordinate2D
    let defaultAddress: String?

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var alertRadius: Double = 50

    let onSave: (_ name: String?, _ address: String?, _ alertRadius: Double) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Location Info") {
                    TextField("Name (e.g., Home, School)", text: $name)

                    TextField("Address (optional)", text: $address)
                        .textInputAutocapitalization(.words)

                    HStack {
                        Text("Radius (km)")
                        Spacer()
                        Text("\(Int(alertRadius))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $alertRadius, in: 1...200, step: 1)
                }

                Section("Coordinates") {
                    HStack {
                        Text("Lat")
                        Spacer()
                        Text(String(format: "%.5f", coordinate.latitude))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Lng")
                        Spacer()
                        Text(String(format: "%.5f", coordinate.longitude))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

                        onSave(
                            finalName.isEmpty ? nil : finalName,
                            finalAddress.isEmpty ? (defaultAddress?.isEmpty == true ? nil : defaultAddress) : finalAddress,
                            alertRadius
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                if address.isEmpty {
                    address = defaultAddress ?? ""
                }
            }
        }
    }
}

