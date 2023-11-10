//
//  SPUSNatConsentSpec.swift
//  ConsentViewController_ExampleTests
//
//  Created by Andre Herculano on 02.11.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

@testable import ConsentViewController
import Foundation
import Nimble
import Quick

class SPUSNatConsentsSpec: QuickSpec {
    override func spec() {
        // TODO: remove fdescribe
        fdescribe("static empty()") {
            it("contain empty defaults for all its fields") {
                let consents = SPUSNatConsent.empty()
                expect(consents.uuid).to(beNil())
                expect(consents.applies).to(beFalse())
                expect(consents.dateCreated.date.doubleValue).to(beCloseTo(SPDate(date: Date()).date.doubleValue, within: 0.001))
            }
        }

        // TODO: remove fit
        fit("is Codable") {
            let usnatConsents = Result { """
                {
                    "applies": true,
                    "dateCreated": "2023-02-06T16:20:53.707Z",
                    "expirationDate": "2024-02-06T16:20:53.707Z",
                    "consentString": "ABC",
                    "categories": ["foo"],
                    "consentStatus": {
                        "granularStatus": {},
                        "hasConsentData": false
                    }
                }
                """.data(using: .utf8)
            }
            let consent = try usnatConsents.decoded() as SPUSNatConsent
            expect(consent.applies).to(beTrue())
            expect(consent.categories).to(equal(["foo"]))
            expect(consent.consentString).to(equal("ABC"))
            expect(consent.dateCreated).to(equal(year: 2023, month: 2, day: 6))
            expect(consent.expirationDate).to(equal(year: 2024, month: 2, day: 6))
            expect(consent.consentStatus).to(equal(ConsentStatus()))
        }
    }
}
