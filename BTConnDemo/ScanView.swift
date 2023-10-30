//
//  ScanView.swift
//  BTConnDemo
//
//  Created by Alex Birleanu on 09.10.2023.
//

import SwiftUI

struct ScanView: View {
    var body: some View {
        Button {
            viewModel.scan()
        } label: {
            Text("Start Scan")
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ScanView()
}
