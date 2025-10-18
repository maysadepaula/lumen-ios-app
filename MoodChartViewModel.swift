import Foundation
import Combine

final class MoodChartViewModel: ObservableObject {
    @Published var moods: [MoodEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository = MoodRepository()
    
    func fetchMoodHistory() {
        // Ativa o indicador de carregamento
        self.isLoading = true
        self.errorMessage = nil
        
        repository.fetchMoods { [weak self] result in
            // Garante que a atualização da UI seja na thread principal
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedMoods):
                    // Publica os dados recebidos da nuvem
                    self?.moods = fetchedMoods
                case .failure(let error):
                    self?.errorMessage = "Erro ao carregar o histórico."
                    print("❌ Erro ao buscar humores para o gráfico: \(error.localizedDescription)")
                }
            }
        }
    }
}
