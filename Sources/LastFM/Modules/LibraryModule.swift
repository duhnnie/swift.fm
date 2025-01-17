import Foundation

public struct LibraryModule {

    internal enum APIMethod: String, MethodKey {
        case getArtists = "getartists"

        func getName() -> String {
            return "library.\(self.rawValue)"
        }
    }

    private let parent: LastFM
    private let requester: Requester
    private let secure: Bool

    internal init(parent: LastFM, secure: Bool, requester: Requester = RequestUtils.shared) {
        self.parent = parent
        self.requester = requester
        self.secure = secure
    }
    
    @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func getArtists(params: SearchParams) async throws -> CollectionPage<LibraryArtist> {
        let params = parent.normalizeParams(
            params: params.toDictionary(termKey: "user"),
            method: APIMethod.getArtists
        )
        
        return try await requester.getDataAndParse(
            params: params,
            type: CollectionPage<LibraryArtist>.self,
            secure: self.secure
        )
    }

    public func getArtists(
        params: SearchParams,
        onCompletion: @escaping LastFM.OnCompletion<CollectionPage<LibraryArtist>>
    ) {
        let params = parent.normalizeParams(
            params: params.toDictionary(termKey: "user"),
            method: APIMethod.getArtists
        )

        requester.getDataAndParse(params: params, secure: self.secure, onCompletion: onCompletion)
    }

}
