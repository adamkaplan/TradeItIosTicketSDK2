import UIKit
import TradeItIosTicketSDK2
import TradeItIosEmsApi

enum Action: Int {
    case LaunchSdk = 0
    case LaunchPortfolio = 1
    case DeleteLinkedBrokers = 2
    case ENUM_COUNT
}

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!

    let API_KEY = "tradeit-fx-test-api-key" //"tradeit-test-api-key"
    let ENVIRONMENT = TradeItEmsTestEnv
    var tradeItLauncher: TradeItLauncher!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItLauncher = TradeItLauncher(apiKey: API_KEY, environment: ENVIRONMENT)
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = Action(rawValue: indexPath.row) else { return }

        switch action {
        case .LaunchSdk:
            self.tradeItLauncher.launchTradeIt(fromViewController: self)
        case .LaunchPortfolio:
            self.launchTradeItPortfolioFromViewController()
        case .DeleteLinkedBrokers:
            self.deleteLinkedBrokers()
        default:
            return
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Action.ENUM_COUNT.rawValue;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }

        if let action = Action(rawValue: indexPath.row) {
            cell?.textLabel?.text = "\(action)"
        }
        
        return cell!
    }
    
    // MARK: private
    private func deleteLinkedBrokers() -> Void {
        let tradeItConnector = TradeItConnector(apiKey: self.API_KEY)!
        tradeItConnector.environment = self.ENVIRONMENT

        let linkedLogins = tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
        for linkedLogin in linkedLogins {
            tradeItConnector.unlinkLogin(linkedLogin)
        }
    }

    func launchTradeItPortfolioFromViewController() {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2") )
        let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_NAV_VIEW") as! UINavigationController
        let portfolioViewController = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_PORTFOLIO_VIEW")

        navigationViewController.viewControllers = [portfolioViewController]
        self.presentViewController(navigationViewController, animated: true, completion: nil)
    }
}