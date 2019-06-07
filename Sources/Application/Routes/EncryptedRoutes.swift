//
//  EncryptedRoutes.swift
//  Application
//
//  Created by David Jones on 07/06/2019.
//

import Foundation
import Kitura

@available(OSX 10.13, *)
func initializeEncryptedRoutes(app: App) {

    // Handler that receives JSON that can be decoded into the EncryptedContainer type,
    // then decrypts it using facilities that EncryptedContainer provides, into a User type.
    //
    // For the purposes of this example, I've attached an 'iteration' property to the User
    // so that we can increment it on each round of message passing, demonstrating that
    // the route handler was able to decrypt the request and encrypt the response.
    //
    // A new User instance is created with the same name with its 'iteration' property
    // incremented, this is then encrypted into a new EncryptedContainer, and returned to
    // the client.
    //
    // The Codable Router is responsible for decoding the initial EncryptedContainer type
    // from the HTTP request, and for encoding the resulting EncryptedContainer into the
    // response.
    //
    // The EncryptedContainer type itself is responsible for decrypting and decoding a User
    // type from its own data, and for initializing itself from a User. Both of these
    // operations require a key - in this example I have used BlueECC which provides an
    // easy way to perform elliptic curve crypto.
    //
    func postEncrypted(container: EncryptedContainer<User>, respondWith: (EncryptedContainer<User>?, RequestError?) -> Void) {
        // Check that we can decrypt a User type from the encrypted data
        guard let user = container.decrypt(privateKey: app.eccPrivateKey) else {
            print("Unable to extract user")
            return respondWith(nil, .badRequest)
        }
        // For testing purposes, display the user that was received
        print("User name = \(user.name), iteration: \(user.iteration)")

        // Construct a new User incrementing the 'iteration' value, for the purposes of
        // demonstrating that we were able to decrypt and decode the data we received
        let myUser = User(name: user.name, iteration: user.iteration+1)

        // Encrypt the User into an EncryptedUser, to send as the response
        guard let result = EncryptedContainer(encrypting: myUser, with: app.eccPublicKey) else {
            return respondWith(nil, .internalServerError)
        }
        respondWith(result, nil)
    }

    // Register our POST handler with the Router
    app.router.post("/encrypted", handler: postEncrypted)

    // For testing purposes, produce some valid encrypted data to post. This can be
    // copy-pasted into a curl command to drive requests to the server. For example:
    //
    // curl -d'{ "payload": "<base64 string>" }' -H 'Content-Type: application/json' http://localhost:8080/encrypted
    //
    let sampleUser = User(name: "Dave", iteration: 1)
    let encryptedUser = EncryptedContainer(encrypting: sampleUser, with: app.eccPublicKey)!
    print("Sample payload: { \"payload\": \"\(encryptedUser.payload)\" }")
}
