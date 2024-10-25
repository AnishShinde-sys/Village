import SwiftUI

struct ParentHomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to the Parent Dashboard")
                    .font(.largeTitle)
                    .padding()

                // Add additional content here, such as buttons or information
                // For example:
                Text("Here you can manage your village and keep track of your kids.")
                    .font(.headline)
                    .padding()

                // Add navigation links or buttons to other features
                // For example:
                NavigationLink(destination: VillageView()) {
                    Text("Go to Village")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Parent Home")
        }
    }
}

struct ParentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ParentHomeView()
    }
}
