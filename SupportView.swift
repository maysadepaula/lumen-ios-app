import SwiftUI

struct SupportView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Canais de Escuta e Apoio")) {
                    Link("Falar com Psicólogo", destination: URL(string: "tel://08001234567")!)
                    Link("Enviar E-mail para RH", destination: URL(string: "mailto:rh.bemestar@empresa.com")!)
                }
                
                Section(header: Text("Dicas Rápidas de Bem-Estar")) {
                    Text("🧘‍♀️ Lembre-se de fazer pausas curtas a cada hora de trabalho.")
                    Text("💧 Beba água regularmente ao longo do dia.")
                    Text("🚶‍♂️ Uma breve caminhada pode melhorar seu humor e criatividade.")
                    Text("😌 Pratique a respiração consciente por 1-2 minutos quando se sentir sobrecarregado.")
                }
                
                Section(header: Text("Recursos Externos")) {
                    Link("CVV - Centro de Valorização da Vida", destination: URL(string: "https://www.cvv.org.br")!)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Apoio")
        }
    }
}
