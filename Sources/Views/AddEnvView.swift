// Sources/Views/AddEnvView.swift
import SwiftUI

struct AddEnvView: View {
    let variables: [EnvVariable]
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var keyName = ""
    @State private var keyValue = ""
    @State private var baseURL = ""
    @State private var errorMessage: String?

    private var isDuplicate: Bool {
        variables.contains { $0.name == keyName }
    }

    private var canSave: Bool {
        !keyName.isEmpty && !keyValue.isEmpty && !isDuplicate
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("← 返回") { onCancel() }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                Spacer()
                Text("添加 API")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Key name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Key 名称")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField("OPENAI_API_KEY", text: $keyName)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, design: .monospaced))
                        if isDuplicate {
                            Text("⚠️ 该变量名已存在")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                        }
                    }

                    // Key value
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Key 值")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        SecureField("sk-proj-...", text: $keyValue)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, design: .monospaced))
                    }

                    // Base URL
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Base URL")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("选填")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        TextField("https://api.openai.com", text: $baseURL)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, design: .monospaced))
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    // Save button
                    Button(action: save) {
                        Text("保存到环境变量")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                    .padding(.top, 8)

                    Text("自动写入 ~/.zshrc 并立即生效")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
            }
        }
    }

    private func save() {
        do {
            let content = try String(contentsOfFile: ZshrcService.zshrcPath, encoding: .utf8)
            let updated = ZshrcService.addExport(
                to: content,
                name: keyName,
                value: keyValue,
                baseURL: baseURL.isEmpty ? nil : baseURL
            )
            try ZshrcService.writeAndSource(updated)
            onSave()
        } catch {
            errorMessage = "写入失败: \(error.localizedDescription)"
        }
    }
}
