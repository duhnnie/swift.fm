import XCTest
@testable import LastFM

class TagModuleTests: XCTestCase {

    private static let lastFM = LastFM(
        apiKey: Constants.API_KEY,
        apiSecret: Constants.API_SECRET
    )

    private var instance: TagModule!
    private var apiClientMock = APIClientMock()

    override func setUpWithError() throws {
        instance = TagModule(
            instance: Self.lastFM,
            requester: RequestUtils(apiClient: apiClientMock)
        )
    }

    override func tearDownWithError() throws {
        apiClientMock.clearMock()
    }

    // getTopTracks

    func test_getTopTracks_success() throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/tag.getTopTracks", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let expectedEntity = try JSONDecoder().decode(CollectionPage<TagTopTrack>.self, from: fakeData)
        let params = TagTopTracksParams(tag: "Pop punk", limit: 5, page: 1)
        let expectation = expectation(description: "waiting for getTopTracks")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getTopTracks(params: params) { result in
            switch(result) {
            case .success(let list):
                XCTAssertEqual(list, expectedEntity)
            case .failure(let error):
                XCTFail("Expected to fail. Got \"\(error.localizedDescription)\" error instead")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertNil(apiClientMock.getCalls[0].headers)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=tag.gettoptracks&api_key=\(Constants.API_KEY)&limit=\(params.limit)&format=json&tag=\(params.tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&page=1"
            )
        )
    }

    func test_getTopTracks_failure() throws {
        let params = TagTopTracksParams(tag: "Some Tag", limit: 35, page: 5)

        apiClientMock.error = RuntimeError("Some error")

        instance.getTopTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("Expected to fail, but it succeeded")
            case .failure(_):
                XCTAssertTrue(true)
            }
        }
    }

    // getTopArtists

    func test_getTopArtists_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/tag.getTopArtists",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectedEntity = try JSONDecoder().decode(CollectionPage<TagTopArtist>.self, from: fakeData)
        let params = TagTopArtistsParams(tag: "Progressive", limit: 5, page: 1)
        let expectation = expectation(description: "waiting for getTopArtists")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getTopArtists(params: params) { result in
            switch(result) {
            case .success(let list):
                XCTAssertEqual(list, expectedEntity)
            case .failure(let error):
                XCTFail("Expected to fail. Got \"\(error.localizedDescription)\" error instead")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertNil(apiClientMock.getCalls[0].headers)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=tag.gettopartists&api_key=\(Constants.API_KEY)&limit=\(params.limit)&format=json&tag=\(params.tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&page=1"
            )
        )

    }

    func test_getTopAlbums_success() throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/tag.getTopAlbums", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = TagTopAlbumsParams(tag: "Experimental", limit: 5, page: 12)
        let expectation = expectation(description: "waiting for getTopAlbums")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getTopAlbums(params: params) { result in
            switch(result) {
            case .success(let entity):
                XCTAssertEqual(entity.items.count, 5)
                XCTAssertEqual(entity.items[0].artist.name, "Grimes")

                XCTAssertEqual(
                    entity.items[0].artist.mbid,
                    "7e5a2a59-6d9f-4a17-b7c2-e1eedb7bd222"
                )

                XCTAssertEqual(
                    entity.items[0].artist.url.absoluteString,
                    "https://www.last.fm/music/Grimes"
                )

                XCTAssertEqual(
                    entity.items[0].images.small!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/34s/c403c8620830e646a8f9eabcadb8c8a7.png"
                )

                XCTAssertEqual(
                    entity.items[0].images.medium!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/64s/c403c8620830e646a8f9eabcadb8c8a7.png"
                )

                XCTAssertEqual(
                    entity.items[0].images.large!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/174s/c403c8620830e646a8f9eabcadb8c8a7.png"
                )

                XCTAssertEqual(
                    entity.items[0].images.extraLarge!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/300x300/c403c8620830e646a8f9eabcadb8c8a7.png"
                )

                XCTAssertNil(entity.items[0].images.mega)
                XCTAssertEqual(entity.items[0].rank, 1)
                XCTAssertEqual(entity.pagination.page, 1)
                XCTAssertEqual(entity.pagination.perPage, 5)
                XCTAssertEqual(entity.pagination.total, 38538)
                XCTAssertEqual(entity.pagination.totalPages, 7708)
            case .failure(let error):
                XCTFail("Expected to succeed, but it fail with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=tag.gettopalbums&tag=\(params.tag)&limit=\(params.limit)&page=\(params.page)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }

    // getInfo

    func test_getInfo() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/tag.getInfo",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getInfo(name: "indie", lang: "en") { result in
            switch (result) {
            case .success(let tagInfo):
                XCTAssertEqual(tagInfo.name, "indie")
                XCTAssertEqual(tagInfo.total, 2046784)
                XCTAssertEqual(tagInfo.reach, 257873)
                XCTAssertEqual(tagInfo.wiki.summary, "Indie tag summary.")
                XCTAssertEqual(tagInfo.wiki.content, "Indie tag content.")
            case .failure(let error):
                XCTFail("Expected to succeed, but it fail with error \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)
        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=tag.getinfo&format=json&name=indie&lang=en&api_key=someAPIKey"
            )
        )
    }
    
}
