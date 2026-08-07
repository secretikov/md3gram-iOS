import SwiftUI

public struct MD3TextFieldStyle: TextFieldStyle {
    @Environment(\.md3Theme) var theme

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(theme.surfaceVariant)
            .cornerRadius(4)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(theme.outline),
                alignment: .bottom
            )
            .foregroundColor(theme.onSurface)
    }
}

public struct MD3ButtonStyle: ButtonStyle {
    @Environment(\.md3Theme) var theme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(theme.onPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(configuration.isPressed ? theme.primary.opacity(0.8) : theme.primary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

public struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.md3Theme) var theme

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("Telegram")
                .font(.largeTitle)
                .foregroundColor(theme.primary)
                .padding(.bottom, 24)

            if viewModel.currentState == .waitTdlibParameters {
                Button("Initialize") {
                    viewModel.setTdlibParameters()
                }
                .buttonStyle(MD3ButtonStyle())

            } else if viewModel.currentState == .waitPhoneNumber {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.caption)
                        .foregroundColor(theme.primary)
                    TextField("Enter phone number", text: $viewModel.phoneNumber)
                        .textFieldStyle(MD3TextFieldStyle())
                        .keyboardType(.phonePad)
                }

                Button("Send Code") {
                    viewModel.sendPhoneNumber()
                }
                .buttonStyle(MD3ButtonStyle())
                .disabled(viewModel.isLoading)

            } else if viewModel.currentState == .waitCode {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SMS Code")
                        .font(.caption)
                        .foregroundColor(theme.primary)
                    TextField("Enter SMS code", text: $viewModel.smsCode)
                        .textFieldStyle(MD3TextFieldStyle())
                        .keyboardType(.numberPad)
                }

                Button("Verify") {
                    viewModel.sendCode()
                }
                .buttonStyle(MD3ButtonStyle())
                .disabled(viewModel.isLoading)

            } else if viewModel.currentState == .waitPassword {
                VStack(alignment: .leading, spacing: 8) {
                    Text("2FA Password")
                        .font(.caption)
                        .foregroundColor(theme.primary)
                    SecureField("Enter password", text: $viewModel.password)
                        .textFieldStyle(MD3TextFieldStyle())
                }

                Button("Submit") {
                    viewModel.sendPassword()
                }
                .buttonStyle(MD3ButtonStyle())
                .disabled(viewModel.isLoading)

            } else if viewModel.currentState == .ready {
                Text("Authenticated successfully!")
                    .foregroundColor(theme.primary)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }

            Spacer()
        }
        .padding(24)
        .background(theme.background.ignoresSafeArea())
    }
}
