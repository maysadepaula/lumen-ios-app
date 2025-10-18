import SwiftUI
import Charts

struct MoodChartView: View {
    @StateObject private var vm = MoodChartViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Se estiver carregando, mostra um indicador
                if vm.isLoading {
                    ProgressView("Carregando dados...")
                }
                // Se não estiver carregando, mostra o gráfico ou a mensagem de erro/vazio
                else if vm.moods.isEmpty {
                    Text(vm.errorMessage ?? "Nenhum dado de humor registrado para exibir no gráfico.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Chart(vm.moods) { entry in
                        LineMark(
                            x: .value("Data", entry.date, unit: .day),
                            y: .value("Humor", entry.moodScore)
                        )
                        .foregroundStyle(.blue.gradient)
                        
                        PointMark(
                            x: .value("Data", entry.date, unit: .day),
                            y: .value("Humor", entry.moodScore)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .top) {
                            Text(entry.mood)
                        }
                    }
                    .chartYScale(domain: 0...6)
                    .padding()
                }
            }
            .navigationTitle("Sua Evolução")
            .onAppear {
                vm.fetchMoodHistory()
            }
        }
    }
}
