// Sources/Views/ContentView.swift
import SwiftUI

enum AppTab {
    case apiKeys
    case skills
}

enum EnvViewState {
    case list
    case add
    case edit(EnvVariable)
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .apiKeys
    @State private var envViewState: EnvViewState = .list
    @State private var variables: [EnvVariable] = []
    @State private var envSearchText = ""
    @State private var skills: [Skill] = []
    @State private var skillSearchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                TabButton(
                    title: "🔑 API Keys",
                    isSelected: selectedTab == .apiKeys,
                    action: { selectedTab = .apiKeys }
                )
                TabButton(
                    title: "⚡ Skills",
                    isSelected: selectedTab == .skills,
                    action: { selectedTab = .skills }
                )
            }

            // Content
            switch selectedTab {
            case .apiKeys:
                apiKeysContent
            case .skills:
                SkillListView(skills: $skills, searchText: $skillSearchText)
            }
        }
        .frame(width: 420, height: 500)
        .onAppear {
            variables = ZshrcService.loadVariables()
            skills = SkillService.loadAllSkills()
        }
    }

    @ViewBuilder
    private var apiKeysContent: some View {
        switch envViewState {
        case .list:
            EnvListView(
                variables: $variables,
                searchText: $envSearchText,
                onAdd: { envViewState = .add },
                onEdit: { envVar in envViewState = .edit(envVar) }
            )
        case .add:
            AddEnvView(
                variables: variables,
                onSave: { reloadEnv(); envViewState = .list },
                onCancel: { envViewState = .list }
            )
        case .edit(let envVar):
            EditEnvView(
                envVar: envVar,
                onSave: { reloadEnv(); envViewState = .list },
                onDelete: { reloadEnv(); envViewState = .list },
                onCancel: { envViewState = .list }
            )
        }
    }

    private func reloadEnv() {
        variables = ZshrcService.loadVariables()
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
