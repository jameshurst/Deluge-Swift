public extension Deluge {
    struct Response<Value: Decodable>: Decodable {
        public let id: Int
        public let result: Value
        public let error: Error?

        public struct Error: Decodable {
            public let message: String
            public let code: Int
        }
    }
}
