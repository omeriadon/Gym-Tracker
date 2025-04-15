import SwiftUI

struct CardView<Content: View>: View {
    let systemImage: String
    let title: String
    let content: Content
    
    init(systemImage: String, title: String, @ViewBuilder content: () -> Content) {
        self.systemImage = systemImage
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: systemImage)
                .font(.title2)
                .padding(.horizontal)
                .padding(.top, 12)
            
            
            Spacer()
                .frame(height: 30)
            
            content
                .frame(maxWidth: .infinity, maxHeight: 100)
        }
        .frame(width: UIScreen.main.bounds.width - 20, height: 600)
        .background(UltraThinView().blur(radius:5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
