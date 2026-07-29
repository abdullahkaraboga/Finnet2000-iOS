import SwiftUI

struct StockScannerView: View {

    @State private var selectedTab = 0
    @State private var selectedListTab = 0

    private let primaryGreen = Color(
        red: 0.17,
        green: 0.76,
        blue: 0.49
    )

    var body: some View {

        ZStack {

            Color(
                red: 0.95,
                green: 0.95,
                blue: 0.95
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ÜST TABLAR

                VStack(spacing: 0) {

                    HStack(spacing: 0) {

                        Button {
                            selectedTab = 0
                        } label: {

                            Text("Listeler")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }

                        Button {
                            selectedTab = 1
                        } label: {

                            Text("Tarayıcı")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                    }

                    GeometryReader { geo in

                        ZStack(alignment: .leading) {

                            Color.gray.opacity(0.18)

                            Rectangle()
                                .fill(primaryGreen)
                                .frame(
                                    width: geo.size.width / 2,
                                    height: 2
                                )
                                .offset(
                                    x: selectedTab == 0
                                    ? 0
                                    : geo.size.width / 2
                                )
                        }
                    }
                    .frame(height: 2)
                }
                .background(.white)

                // ALT TABLAR

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button {
                            selectedListTab = 0
                        } label: {
                            Text("Listelerim")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedListTab == 0 ? .gray : primaryGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }

                        Button {
                            selectedListTab = 1
                        } label: {
                            Text("Örnek Listeler")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedListTab == 0 ? .gray : primaryGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                    }


                }
                .background(.white)

                // CONTENT

                VStack {

                    if selectedListTab == 0 {
                        // Listelerim içeriği
                    } else {
                        // Örnek Listeler içeriği
                    }

                    Button(action: {}) {

                        HStack(spacing: 8) {

                            Image(systemName: "plus")
                                .font(.system(size: 16))

                            Text("Yeni Liste Oluştur")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.black)
                        .frame(width: 200, height: 40)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    primaryGreen,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .padding(.top, 12)

                    Spacer()
                }

                Spacer()
            }
        }
        .navigationTitle("Hisse Filtreleme")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    StockScannerView()
}
