import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import CryptorECC

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

@available(OSX 10.13, *)
public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    let eccPrivateKey: ECPrivateKey
    let eccPublicKey: ECPublicKey
    let privateKeyPEM: String
    let publicKeyPEM: String

    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
        eccPrivateKey = try ECPrivateKey.make(for: .prime256v1)
        privateKeyPEM = eccPrivateKey.pemString
        eccPublicKey = try eccPrivateKey.extractPublicKey()
        publicKeyPEM = eccPublicKey.pemString
        print("Private key:\n\(privateKeyPEM)")
        print("Public key:\n\(publicKeyPEM)")
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        initializeEncryptedRoutes(app: self)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
