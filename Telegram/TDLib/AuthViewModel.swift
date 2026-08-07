import Foundation
import Combine

@MainActor
public class AuthViewModel: ObservableObject {
    @Published public var phoneNumber: String = ""
    @Published public var smsCode: String = ""
    @Published public var password: String = ""

    @Published public var currentState: TDLibState = .waitTdlibParameters
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let tdlib: TDLibService
    private var cancellables = Set<AnyCancellable>()

    public init(tdlib: TDLibService = .shared) {
        self.tdlib = tdlib

        tdlib.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.currentState = state
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    public func sendPhoneNumber() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "setAuthenticationPhoneNumber",
                    "phone_number": phoneNumber
                ]
                let _ = try await tdlib.execute(query: query)
                // Assuming TDLib state updates will trigger state change

                // For mock purposes:
                tdlib.simulateUpdate([
                    "@type": "updateAuthorizationState",
                    "authorization_state": ["@type": "authorizationStateWaitCode"]
                ])
            } catch {
                self.errorMessage = "Failed to send phone number."
                self.isLoading = false
            }
        }
    }

    public func sendCode() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "checkAuthenticationCode",
                    "code": smsCode
                ]
                let _ = try await tdlib.execute(query: query)

                // For mock purposes:
                tdlib.simulateUpdate([
                    "@type": "updateAuthorizationState",
                    "authorization_state": ["@type": "authorizationStateWaitPassword"] // or ready
                ])
            } catch {
                self.errorMessage = "Failed to send SMS code."
                self.isLoading = false
            }
        }
    }

    public func sendPassword() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "checkAuthenticationPassword",
                    "password": password
                ]
                let _ = try await tdlib.execute(query: query)

                // For mock purposes:
                tdlib.simulateUpdate([
                    "@type": "updateAuthorizationState",
                    "authorization_state": ["@type": "authorizationStateReady"]
                ])
            } catch {
                self.errorMessage = "Failed to send password."
                self.isLoading = false
            }
        }
    }

    public func setTdlibParameters() {
        isLoading = true
        Task {
            do {
                let query: [String: Any] = [
                    "@type": "setTdlibParameters",
                    "use_test_dc": false,
                    "database_directory": "tdlib",
                    "use_file_database": true,
                    "use_chat_info_database": true,
                    "use_message_database": true,
                    "api_id": 123456, // dummy
                    "api_hash": "dummy_hash",
                    "system_language_code": "en",
                    "device_model": "iOS",
                    "application_version": "1.0"
                ]
                let _ = try await tdlib.execute(query: query)

                // For mock purposes:
                tdlib.simulateUpdate([
                    "@type": "updateAuthorizationState",
                    "authorization_state": ["@type": "authorizationStateWaitPhoneNumber"]
                ])
            } catch {
                self.errorMessage = "Failed to init parameters"
                self.isLoading = false
            }
        }
    }
}
