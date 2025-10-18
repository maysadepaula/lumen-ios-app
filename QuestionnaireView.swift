import SwiftUI

struct QuestionnaireView: View {
    @StateObject private var vm = QuestionnaireViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($vm.questions) { $q in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(q.text)
                                .font(.headline)
                            
                            Picker("Resposta", selection: $q.answer) {
                                Text("N/A").tag(Optional<Int>(nil)) 
                                ForEach(1..<6) { val in
                                    Text("\(val)").tag(Optional(val))
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Button(action: vm.submitAnswers) {
                    Text("Enviar Avaliação")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.isSubmitted ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(vm.isSubmitted)
                .padding()

            }
            .navigationTitle("Avaliação")
            .alert(isPresented: $vm.showAlert) {
                Alert(title: Text("Lumen"), message: Text(vm.submissionMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
