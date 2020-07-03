//
//  SPGDPRExampleAppUITests.swift
//  SPGDPRExampleAppUITests
//
//  Created by Andre Herculano on 19.06.20.
//  Copyright © 2020 All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import ConsentViewController

class SPGDPRExampleAppUITests: QuickSpec {
    var app: ExampleApp!

    override func spec() {
        beforeSuite {
            self.continueAfterFailure = false
            self.app = ExampleApp()
            Nimble.AsyncDefaults.Timeout = 10
            Nimble.AsyncDefaults.PollInterval = 0.5
        }

        afterSuite {
            Nimble.AsyncDefaults.Timeout = 1
            Nimble.AsyncDefaults.PollInterval = 0.01
        }

        beforeEach {
            self.app.relaunch(clean: true)
        }

        it("Accept all through message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.acceptAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Accepted"))
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }

        it("Reject all through message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Rejected"))
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }

        it("Accept all through privacy manager via message") {
            self.app.showOptionsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.acceptAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Accepted"))
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }

        it("Reject all through privacy manager via message") {
            self.app.showOptionsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Rejected"))
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }

        it("Save and Exit through privacy manager via message") {
            self.app.showOptionsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.saveAndExitButton.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }

        it("Have the vendor x 'Rejected' after tapping on Clear Consents button") {
            self.app.acceptAllButton.tap()
            self.app.clearConsentButton.tap()
            expect(self.app.vendorXConsentStatus).to(equal("Rejected"))
        }

        it("Have the vendor x 'Accepted' after tapping on Accept Vendor X button") {
            self.app.rejectAllButton.tap()
            expect(self.app.vendorXConsentStatus).to(equal("Rejected"))
            self.app.acceptVendorXButton.tap()
            expect(self.app.vendorXConsentStatus).to(equal("Accepted"))
        }

        it("Accept all through the Privacy Manager directly") {
            self.app.rejectAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.acceptAllButton.tap()
            expect(self.app.privacyManager).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Accepted"))
        }

        it("Reject all through the Privacy Manager directly") {
            self.app.acceptAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.privacyManager).to(disappear())
            expect(self.app.vendorXConsentStatus).to(equal("Rejected"))
        }

        it("Save And Exit through the Privacy Manager directly") {
            self.app.acceptAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.saveAndExitButton.tap()
            expect(self.app.privacyManager).to(disappear())
        }
    }
}

