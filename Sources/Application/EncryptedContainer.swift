//
//  EncryptedContainer.swift
//  Application
//
//  Created by David Jones on 07/06/2019.
//

import Foundation
import CryptorECC

// A container that matches the on-the-wire JSON format data which contains an encrypted field.
// The encrypted field, when decrypted, contains a JSON representation of another type, which
// can be retrieved by calling decrypt().
@available(OSX 10.13, *)
struct EncryptedContainer<T: Codable>: Codable {
    // Encrypted content in base64 encoded format
    let payload: String

    // Create a new EncryptedContainer by encoding a given Codable type to JSON, and then
    // encrypting the serialized form with the supplied key.
    init?(encrypting value: T, with publicKey: ECPublicKey) {
        let encoder = JSONEncoder()
        do {
            let decrypted = try encoder.encode(value)
            let encrypted = try decrypted.encrypt(with: publicKey)
            payload = encrypted.base64EncodedString()
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }

    // Decrypt a Codable type from the payload.
    func decrypt(privateKey: ECPrivateKey) -> T? {
        let dataMaybe = Data(base64Encoded: payload)
        guard let data = dataMaybe else {
            print("Data was not base64 encoded")
            return nil
        }
        do {
            let decrypted = try data.decrypt(with: privateKey)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: decrypted)
        } catch let error as DecodingError {
            print("Error decoding: \(error)")
        } catch {
            print("Error decrypting: \(error)")
        }
        return nil
    }
}
