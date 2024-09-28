//
//  OptionView.swift
//  TrollFools
//
//  Created by Lessica on 2024/7/19.
//

import SwiftUI

private enum Option {
    case attach
    case detach
}

private struct OptionCell: View {
    let option: Option

    var iconName: String {
        if #available(iOS 16.0, *) {
            option == .attach ? "syringe" : "xmark.bin"
        } else {
            option == .attach ? "tray.and.arrow.down" : "xmark.bin"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(option == .attach
                                 ? .accentColor : .red)
                .padding(.all, 40)
            }
            .background(
                (option == .attach ? Color.accentColor : Color.red)
                    .opacity(0.1)
                    .clipShape(RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    ))
            )

            Text(option == .attach 
                 ? NSLocalizedString("Inject", comment: "")
                 : NSLocalizedString("Eject", comment: ""))
                .font(.headline)
                .foregroundColor(option == .attach
                                 ? .accentColor : .red)
        }
    }
}

struct OptionView: View {
    let app: App
    let fPath: String
    
    @State var isImporterPresented = false
    @State var isImporterSelected = false
    
    @State var isSettingsPresented = false
    
    @State var importerResult: Result<[URL], any Error>?
    
    init(_ app: App, _ fPath: String) {
        self.app = app
        self.fPath = fPath
    }
    
    
    var body: some View {
        if !fPath.isEmpty {
            let stringUrls: [String] = [fPath]
            let urlss: [URL] = stringUrls.compactMap { URL(fileURLWithPath: $0) }
            InjectView(app: app, urlList: urlss
                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent }))
        }else {
            VStack(spacing: 80) {
                HStack {
                    Spacer()
                    
                    Button {
                        isImporterPresented = true
                    } label: {
                        OptionCell(option: .attach)
                    }
                    .accessibilityLabel(NSLocalizedString("Inject", comment: ""))
                    
                    Spacer()
                    
                    NavigationLink {
                        EjectListView(app)
                    } label: {
                        OptionCell(option: .detach)
                    }
                    .accessibilityLabel(NSLocalizedString("Eject", comment: ""))
                    
                    Spacer()
                }
                
                Button {
                    isSettingsPresented = true
                } label: {
                    Label(NSLocalizedString("Advanced Settings", comment: ""),
                          systemImage: "gear")
                }
            }
            .padding()
            .navigationTitle(app.name)
            .background(Group {
                NavigationLink(isActive: $isImporterSelected) {
                    if let result = importerResult {
                        switch result {
                        case .success(let urls):
                            InjectView(app: app, urlList: urls
                                .sorted(by: { $0.lastPathComponent < $1.lastPathComponent }))
                        case .failure(let message):
                            FailureView(title: NSLocalizedString("Error", comment: ""),
                                        message: message.localizedDescription)
                        }
                    }
                } label: { }
            })
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [
                    .init(filenameExtension: "dylib")!,
                    .bundle,
                    .framework,
                    .package,
                    .zip,
                    .init(filenameExtension: "deb")!,
                ],
                allowsMultipleSelection: true
            ) {
                result in
                importerResult = result
                isImporterSelected = true
            }
            .sheet(isPresented: $isSettingsPresented) {
                if #available(iOS 16.0, *) {
                    SettingsView(app)
                        .presentationDetents([.medium, .large])
                } else {
                    SettingsView(app)
                }
            }
        }
    }
}
