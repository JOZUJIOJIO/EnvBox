import SwiftUI

struct EditEnvView: View {
    let envVar: EnvVariable
    var onSave: () -> Void
    var onDelete: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("编辑 \(envVar.name) — TODO")
            Button("返回", action: onCancel)
        }
    }
}
