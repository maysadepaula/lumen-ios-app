import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Tenta fazer o login anônimo
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print("❌ Erro no login anônimo: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                print("✅ Login anônimo bem-sucedido com userID: \(user.uid)")
            }
        }
        
        return true
    }
}

@main
struct LumenApp: App {
    // Registra o AppDelegate para ser usado pelo SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // TabView é o container que cria a barra de abas na parte inferior
            TabView {
                CheckInView()
                    .tabItem {
                        Label("Check-in", systemImage: "pencil.and.scribble")
                    }
                
                MoodChartView()
                    .tabItem {
                        Label("Evolução", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                QuestionnaireView()
                    .tabItem {
                        Label("Avaliação", systemImage: "list.bullet.clipboard")
                    }
                
                SupportView()
                    .tabItem {
                        Label("Apoio", systemImage: "heart.fill")
                    }
            }
        }
    }
}
