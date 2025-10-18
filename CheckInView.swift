import SwiftUI

struct CheckInView: View {
    @StateObject private var vm = MoodViewModel()
    private let moods = ["😃", "🙂", "😐", "😔", "😩"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Como você está se sentindo agora?")
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Seleção de humor em Grade
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(moods, id: \.self) { m in
                            Text(m)
                                .font(.system(size: 40))
                                .padding()
                                .background(vm.selectedMood == m ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                                .clipShape(Circle())
                                .onTapGesture { vm.selectedMood = m }
                        }
                    }
                    .padding(.horizontal)

                    // Slider de Intensidade
                    VStack {
                        Text("Intensidade: \(vm.moodScore)")
                            .font(.headline)
                        Slider(value: Binding(get: {
                            Double(vm.moodScore)
                        }, set: { newVal in
                            vm.moodScore = Int(newVal)
                        }), in: 1...5, step: 1)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Campo de anotação
                    VStack(alignment: .leading) {
                        Text("Alguma anotação? (Opcional)")
                            .font(.headline)
                        TextEditor(text: $vm.note)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Botão de salvar
                    Button(action: vm.saveCheckIn) {
                        Text("Salvar Check-in")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                }
                .padding(.top)
                .navigationTitle("Check-in Diário")
                .alert(isPresented: $vm.showAlert) {
                    Alert(title: Text("Lumen"), message: Text(vm.lastSavedMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}
