@objc public class TradeItBrokerCenterService: NSObject {
    let apiKey: String
    let environment: TradeitEmsEnvironments

    init(apiKey: String, environment: TradeitEmsEnvironments) {
        self.apiKey = apiKey
        self.environment = environment
    }

    public func getUrl() -> String {
        return TradeItJsonConverter.getEmsHost(forEnvironment: environment) + "brokerCenter?apiKey=\(apiKey)"
    }
}
