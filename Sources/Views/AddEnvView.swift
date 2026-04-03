import SwiftUI

struct AddEnvView: View {
    let variables: [EnvVariable]
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("添加 API — TODO")
            Button("返回", action: onCancel)
        }
    }
}
