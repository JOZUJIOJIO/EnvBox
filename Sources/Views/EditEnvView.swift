// Sources/Views/EditEnvView.swift
import SwiftUI

struct EditEnvView: View {
    let envVar: EnvVariable
    var onSave: () -> Void
    var onDelete: () -> Void
    var onCancel: () -> Void

    @State private var newValue: String = ""
    @State private var showValue = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("← 返回") { onCancel() }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                Spacer()
                Text("编辑变量")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Key name (read-only)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Key 名称")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(envVar.name)
                            .font(.system(size: 14, design: .monospaced))
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(6)
                        Text("名称不可修改")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    // Key value
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Key 值")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(showValue ? "隐藏" : "显示") {
                                showValue.toggle()
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        }
                        if showValue {
                            TextField("", text: $newValue)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 14, design: .monospaced))
                        } else {
                            SecureField("", text: $newValue)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 14, design: .monospaced))
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    // Save button
                    Button(action: save) {
                        Text("保存修改")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newValue.isEmpty)
                    .padding(.top, 8)

                    Text("自动更新 ~/.zshrc")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Divider()
                        .padding(.top, 8)

                    // Delete button
                    Button(action: { showDeleteConfirm = true }) {
                        HStack {
                            Text("🗑")
                            Text("删除此变量")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .alert("确认删除", isPresented: $showDeleteConfirm) {
                        Button("删除", role: .destructive, action: delete)
                        Button("取消", role: .cancel) {}
                    } message: {
                        Text("将从 ~/.zshrc 中移除 \(envVar.name)")
                    }
                }
                .padding(16)
            }
        }
        .onAppear {
            newValue = envVar.value
        }
    }

    private func save() {
        guard let lineIndex = envVar.lineIndex else { return }
        do {
            let content = try String(contentsOfFile: ZshrcService.zshrcPath, encoding: .utf8)
            let updated = ZshrcService.updateExport(in: content, lineIndex: lineIndex, newValue: newValue)
            try ZshrcService.writeAndSource(updated)
            onSave()
        } catch {
            errorMessage = "写入失败: \(error.localizedDescription)"
        }
    }

    private func delete() {
        guard let lineIndex = envVar.lineIndex else { return }
        do {
            let content = try String(contentsOfFile: ZshrcService.zshrcPath, encoding: .utf8)
            let updated = ZshrcService.deleteExport(from: content, lineIndex: lineIndex)
            try ZshrcService.writeAndSource(updated)
            onDelete()
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }
}
