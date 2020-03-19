# Deluge

A Combine powered Deluge JSON-RPC API client.

## Usage

```swift
import Combine
import Deluge

var cancellables = Set<AnyCancellable>()

let client = Deluge(baseURL: URL(string: "https://my.torrent.server")!, password: "secret!")
client.request(.authenticate)
    .sink(receiveCompletion: { _ in }, receiveValue: { _ in
        print("Authenticated!")
    })
    .store(in: &cancellables)
```

## Requests

A `Request` describes an RPC method, its arguments, and a function to transform the API response in to a new representation.

There are many requests already built-in. To see the available requests you can can take a look at the [Requests](Sources/Deluge/Requests/) directory or browse through the autocomplete menu when typing `client.request(.`.

```swift
let addMagnetURL = Request<String>(
    method: "core.add_torrent_magnet",
    args: [magnetURL, [String: Any]()],
    transform: { response in
        guard let hash = response["result"] as? String else { return .failure(.unexpectedResponse) }
        return .success(hash)
    }
)
```

## Installation

### Xcode 11+

* Select **File** > **Swift Packages** > **Add Package Dependency...**
* Enter the package repository URL: `https://github.com/jameshurst/Deluge-Swift.git`
* Confirm the version and let Xcode resolve the package

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
