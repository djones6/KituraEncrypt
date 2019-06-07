import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

do {

    HeliumLogger.use(LoggerMessageType.info)

    if #available(OSX 10.13, *) {
        let app = try App()
        try app.run()
    } else {
        // Fallback on earlier versions
    }

} catch let error {
    Log.error(error.localizedDescription)
}
