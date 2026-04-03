import SwiftUI
import AppKit

struct EnvListView: View {
    @Binding var variables: [EnvVariable]
    @Binding var searchText: String
    var onAdd: () -> Void
    var onEdit: (EnvVariable) -> Void

    private var filtered: [EnvVariable] {
        if searchText.isEmpty { return variables }
        return variables.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Text("🔑 EnvBox")
                        .font(.system(size: 15, weight: .semibold))
                    Text("\(variables.count) 个变量")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        TextField("搜索...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(6)
                    .frame(width: 130)

                    Button(action: onAdd) {
                        Text("+ 添加")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filtered) { envVar in
                        EnvRowView(envVar: envVar, onEdit: { onEdit(envVar) })
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }

            Divider()

            HStack {
                Text("hover 显示完整值 · 📋 复制 · ✏️ 编辑")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct EnvRowView: View {
    let envVar: EnvVariable
    var onEdit: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(envVar.name)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                Text(isHovering ? envVar.value : envVar.maskedValue)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(envVar.isURL ? .blue : (envVar.isPath ? .primary : .secondary))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            HStack(spacing: 8) {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(envVar.value, forType: .string)
                }) {
                    Text("📋")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help("复制值")

                Button(action: onEdit) {
                    Text("✏️")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help("编辑")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
