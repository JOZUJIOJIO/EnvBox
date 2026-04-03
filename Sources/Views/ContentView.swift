import SwiftUI

enum ViewState {
    case list
    case add
    case edit(EnvVariable)
}

struct ContentView: View {
    @State private var viewState: ViewState = .list
    @State private var variables: [EnvVariable] = []
    @State private var searchText = ""

    var body: some View {
        Group {
            switch viewState {
            case .list:
                EnvListView(
                    variables: $variables,
                    searchText: $searchText,
                    onAdd: { viewState = .add },
                    onEdit: { envVar in viewState = .edit(envVar) }
                )
            case .add:
                AddEnvView(
                    variables: variables,
                    onSave: { reload(); viewState = .list },
                    onCancel: { viewState = .list }
                )
            case .edit(let envVar):
                EditEnvView(
                    envVar: envVar,
                    onSave: { reload(); viewState = .list },
                    onDelete: { reload(); viewState = .list },
                    onCancel: { viewState = .list }
                )
            }
        }
        .frame(width: 420, height: 500)
        .onAppear { reload() }
    }

    private func reload() {
        variables = ZshrcService.loadVariables()
    }
}
