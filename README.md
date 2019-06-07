Sample Kitura application demonstating user encryption/decryption of an HTTP payload as part of a Codable route.

## Usage

Build and run the server.  It will produce some output on the console containing an encrypted message that you can send to the Codable route:

```
Sample payload: { "payload": "BIIEpvZxtQyCqDHtLHZbkTLNybcYo8HqlEbxksvg2nwuZ7uXUKLJTL/KZSG+W8IKLKiBHP4HrNNFNYu0/VKYnqodAyL9yEpKh1K/vl5XXq0oj4wjKWDs/JvImYXNIY5EWPZRmRZ5+1prbzdKWUA=" }
```

Copy the JSON fragment from your server output into a `curl` command as follows:
```
curl -d'<JSON payload>' -H 'Content-Type: application/json' http://localhost:8080/encrypted
```

If successful, the response will be another encrypted payload, which can be posted back to the server again.  The server will also print the decrypted, decoded User data to the console.

Note that the encryption key is generated at startup, so will change each time the server is run.
