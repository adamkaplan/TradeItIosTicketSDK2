import UIKit

class TradeItAlertManager {
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    func showGenericError(tradeItErrorResult tradeItErrorResult: TradeItErrorResult,
                            onViewController viewController: UIViewController,
                                             onFinished: () -> Void = {}) {
        var alertTitle = ""
        var alertMessage = ""
        var alertActionTitle = ""

        if let shortMessage = tradeItErrorResult.shortMessage {
            alertTitle = shortMessage
        }

        if let longMessages = tradeItErrorResult.longMessages {
            alertMessage = (longMessages as! [String]).joinWithSeparator(" ")
        }

        alertActionTitle = "OK"

        self.showOn(viewController: viewController,
                    withAlertTitle: alertTitle,
                    withAlertMessage: alertMessage,
                    withAlertActionTitle: alertActionTitle,
                    onAlertActionTapped: onFinished)
    }

    func show(tradeItErrorResult tradeItErrorResult: TradeItErrorResult,
                onViewController viewController: UIViewController,
                withLinkedBroker linkedBroker: TradeItLinkedBroker,
                                 onFinished : () -> Void) {
        var alertTitle = ""
        var alertMessage = ""
        var alertActionTitle = ""
        var onAlertActionTapped: () -> Void
        let onAlertActionRelinkAccount: () -> Void = {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: viewController,
                linkedBroker: linkedBroker,
                onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                    presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                    linkedBroker.refreshAccountBalances(
                        onFinished: onFinished
                    )
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    onFinished()
                }
            )
        }

        let errorCode = tradeItErrorResult.errorCode()

        if errorCode == TradeItErrorCode.BROKER_AUTHENTICATION_ERROR {
            alertTitle = "Update Login"
            alertMessage = "There seem to be a problem connecting with your \(linkedBroker.linkedLogin.broker) account. Please update your login information."
            alertActionTitle = "Update"
            onAlertActionTapped = onAlertActionRelinkAccount
            self.showOn(viewController: viewController,
                        withAlertTitle: alertTitle,
                        withAlertMessage: alertMessage,
                        withAlertActionTitle: alertActionTitle,
                        onAlertActionTapped: onAlertActionTapped,
                        onCancelActionTapped: onFinished)
        } else if errorCode == TradeItErrorCode.OAUTH_ERROR {
            alertTitle = "Relink \(linkedBroker.linkedLogin.broker) Accounts"
            alertMessage = "For your security, we automatically unlink any accounts that have not been used in the past 30 days. Please relink your accounts."
            alertActionTitle = "Update"
            onAlertActionTapped = onAlertActionRelinkAccount
            self.showOn(viewController: viewController,
                        withAlertTitle: alertTitle,
                        withAlertMessage: alertMessage,
                        withAlertActionTitle: alertActionTitle,
                        onAlertActionTapped: onAlertActionTapped,
                        onCancelActionTapped: onFinished)
        } else {
            self.showGenericError(tradeItErrorResult: tradeItErrorResult,
                                  onViewController: viewController,
                                  onFinished: onFinished)
        }
    }

    func show(securityQuestion securityQuestion: TradeItSecurityQuestionResult,
              onViewController viewController: UIViewController,
                               onAnswerSecurityQuestion: (withAnswer: String) -> Void,
                               onCancelSecurityQuestion: () -> Void) {
        let alertController = TradeItAlertProvider.provideSecurityQuestionAlertWith(
            alertTitle: "Security Question",
            alertMessage: securityQuestion.securityQuestion ?? "No security question provided.",
            multipleOptions: securityQuestion.securityQuestionOptions ?? [],
            alertActionTitle: "Submit",
            onAnswerSecurityQuestion: onAnswerSecurityQuestion,
            onCancelSecurityQuestion: onCancelSecurityQuestion)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    func showOn(viewController viewController: UIViewController,
                withAlertTitle alertTitle: String,
              withAlertMessage alertMessage: String,
          withAlertActionTitle alertActionTitle: String,
                               onAlertActionTapped: () -> Void = {},
                               onCancelActionTapped: (() -> Void)? = nil) {
        let alertController = TradeItAlertProvider.provideAlert(alertTitle: alertTitle,
                                                                alertMessage: alertMessage,
                                                                alertActionTitle: alertActionTitle,
                                                                onAlertActionTapped: onAlertActionTapped,
                                                                onCanceledActionTapped: onCancelActionTapped)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
