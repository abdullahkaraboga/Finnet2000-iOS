import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct AccountInfoView: View {
    @Environment(\.dismiss) private var dismiss

    // Read-only fields (gelecekte API'den doldurulacak)
    @State private var firstName: String = "-"
    @State private var lastName: String = "-"

    // Editable fields
    @State private var phoneNumber: String = ""
    @State private var tcKimlikNo: String = ""
    @State private var birthDate: Date = Date()
    @State private var birthDateSelected: Bool = false
    @State private var showDateSheet: Bool = false
    @State private var selectedGender: Gender = .male
    @State private var receiveEmails: Bool = true
    @State private var showDeleteAlert: Bool = false

    enum Gender { case female, male }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(spacing: 12) {
                    readOnlyField(text: firstName)
                    readOnlyField(text: lastName)

                    editableField(
                        placeholder: "Telefon Numarası",
                        text: $phoneNumber,
                        keyboardType: .phonePad
                    )

                    editableField(
                        placeholder: "TC Kimlik No",
                        text: $tcKimlikNo,
                        keyboardType: .numberPad
                    )

                    dateField

                    genderSelector

                    emailCheckbox

                    saveButton
                        .padding(.top, 8)

                    deleteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showDateSheet) {
            datePickerSheet
        }
        .alert("Hesabı Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {}
        } message: {
            Text("Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Hesap Bilgileri")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Button(action: {}) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color.black)
    }

    // MARK: - Read-Only Field

    private func readOnlyField(text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(.systemBackground),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Editable Field

    private func editableField(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .font(.system(size: 15))
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color(.systemBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Date Field

    private var dateField: some View {
        Button(action: { showDateSheet = true }) {
            HStack {
                Text(birthDateSelected
                     ? birthDate.formatted(.dateTime.day().month(.abbreviated).year())
                     : "Doğum Tarihi")
                    .font(.system(size: 15))
                    .foregroundColor(birthDateSelected ? .primary : Color(.placeholderText))
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color(.systemBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date Picker Sheet

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker(
                "",
                selection: $birthDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(finnetGreen)
            .padding()
            .navigationTitle("Doğum Tarihi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") {
                        birthDateSelected = true
                        showDateSheet = false
                    }
                    .foregroundColor(finnetGreen)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        showDateSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Gender Selector

    private var genderSelector: some View {
        HStack(spacing: 0) {
            genderButton(title: "Kadın", systemIcon: "venus", gender: .female)
            genderButton(title: "Erkek", systemIcon: "mars", gender: .male)
        }
        .background(Color(.systemBackground),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func genderButton(title: String, systemIcon: String, gender: Gender) -> some View {
        Button(action: { selectedGender = gender }) {
            HStack(spacing: 8) {
                Image(systemName: systemIcon)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(selectedGender == gender ? .white : .primary)
            .background(
                selectedGender == gender ? finnetGreen : Color.clear,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Email Checkbox

    private var emailCheckbox: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: { receiveEmails.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(
                            receiveEmails ? finnetGreen : Color(.systemGray3),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)
                        .background(
                            receiveEmails ? finnetGreen.opacity(0.12) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                        )

                    if receiveEmails {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(finnetGreen)
                    }
                }
            }
            .buttonStyle(.plain)

            Text("Finnet2000'e dair bildirim ve haberler hakkında e-posta almak istiyorum.")
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {}) {
            Text("Kaydet")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(finnetGreen,
                            in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delete Account Button

    private var deleteButton: some View {
        Button(action: { showDeleteAlert = true }) {
            Text("Hesabı Sil")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountInfoView()
}
