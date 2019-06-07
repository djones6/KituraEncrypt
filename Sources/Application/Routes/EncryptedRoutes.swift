//
//  EncryptedRoutes.swift
//  Application
//
//  Created by David Jones on 07/06/2019.
//

import Foundation
import Kitura
import CryptorECC

@available(OSX 10.13, *)
func initializeEncryptedRoutes(app: App) {

    func postEncrypted(container: EncryptedUser, respondWith: (EncryptedUser?, RequestError?) -> Void) {
        guard let user = container.decrypt(privateKey: app.eccPrivateKey) else {
            print("Unable to extract user")
            return respondWith(nil, .badRequest)
        }
        print("User name = \(user.name), iteration: \(user.iteration)")

        let myUser = User(name: user.name, iteration: user.iteration+1)
        guard let result = EncryptedUser(encrypting: myUser, with: app.eccPublicKey) else {
            return respondWith(nil, .internalServerError)
        }
        respondWith(result, nil)
    }

    app.router.post("/encrypted", handler:postEncrypted)

    // For testing purposes, produce some valid encrypted data to post
    let sampleUser = User(name: "Dave", iteration: 1)
    let encryptedUser = EncryptedUser(encrypting: sampleUser, with: app.eccPublicKey)!
    print("Sample payload: { \"payload\": \"\(encryptedUser.payload)\" }")
}

@available(OSX 10.13, *)
struct EncryptedUser: Codable {
    // Encrypted content in base64 encoded format
    let payload: String

    init?(encrypting user: User, with publicKey: ECPublicKey) {
        let encoder = JSONEncoder()
        do {
            let decrypted = try encoder.encode(user)
            let encrypted = try decrypted.encrypt(with: publicKey)
            payload = encrypted.base64EncodedString()
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }

    func decrypt(privateKey: ECPrivateKey) -> User? {
        let dataMaybe = Data(base64Encoded: payload)
        guard let data = dataMaybe else {
            print("Data was not base64 encoded")
            return nil
        }
        do {
            let decrypted = try data.decrypt(with: privateKey)
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: decrypted)
        } catch {
            print("Error decrypting: \(error)")
            return nil
        }
    }
}

struct User: Codable {
    let name: String
    let iteration: Int
}

