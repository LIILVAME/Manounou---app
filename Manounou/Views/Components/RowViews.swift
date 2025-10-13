//
//  RowViews.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Child Row View
struct ChildRowView: View {
    let child: FunctionalChild
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Text(String(child.firstName.prefix(1)))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(child.age) ans")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let event: FunctionalEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
            
            Text(event.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Document Row View
struct DocumentRowView: View {
    let document: FunctionalDocument
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                
                Text(document.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(document.dateAdded, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}