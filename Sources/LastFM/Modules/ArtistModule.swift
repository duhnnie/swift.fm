import Foundation

public struct ArtistModule {

    internal enum APIMethod: String, MethodKey {
        case getTopTracks = "gettoptracks"
        case getSimilar = "getsimilar"
        case search
        case getTopAlbums = "gettopalbums"
        case getInfo = "getInfo"

        func getName() -> String {
            return "artist.\(self.rawValue)"
        }
    }

    private let instance: LastFM
    private let requester: Requester

    internal init(instance: LastFM, requester: Requester = RequestUtils.shared) {
        self.instance = instance
        self.requester = requester
    }

    public func getTopTracks(
        params: ArtistTopTracksParams,
        onCompletion: @escaping LastFM.OnCompletion<CollectionPage<ArtistTopTrack>>
    ) {
        let params = instance.normalizeParams(params: params, method: APIMethod.getTopTracks)

        requester.getDataAndParse(params: params, secure: false, onCompletion: onCompletion)
    }

    public func getSimilar(
        params: ArtistSimilarParams,
        onCompletion: @escaping LastFM.OnCompletion<CollectionList<ArtistSimilar>>
    ) {
        let params = instance.normalizeParams(params: params, method: APIMethod.getSimilar)

        requester.getDataAndParse(params: params, secure: false, onCompletion: onCompletion)
    }

    public func search(
        params: SearchParams,
        onCompletion: @escaping LastFM.OnCompletion<SearchResults<ArtistSearchResult>>
    ) {
        let params = instance.normalizeParams(
            params: params.toDictionary(termKey: "artist"),
            method: APIMethod.search
        )

        requester.getDataAndParse(params: params, secure: false, onCompletion: onCompletion)
    }

    public func getTopAlbums(
        params: ArtistTopAlbumsParams,
        onCompletion: @escaping LastFM.OnCompletion<CollectionPage<ArtistTopAlbum>>
    ) {
        let params = instance.normalizeParams(params: params, method: APIMethod.getTopAlbums)

        requester.getDataAndParse(params: params, secure: false, onCompletion: onCompletion)
    }

    public func getInfo(
        params: ArtistInfoParams,
        onCompletion: @escaping LastFM.OnCompletion<ArtistInfo>
    ) {
        let params = instance.normalizeParams(params: params, method: APIMethod.getInfo)

        requester.getDataAndParse(params: params, secure: false, onCompletion: onCompletion)
    }
}
