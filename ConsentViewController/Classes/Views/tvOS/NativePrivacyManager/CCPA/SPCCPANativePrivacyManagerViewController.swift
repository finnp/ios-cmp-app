//
//  SPCCPANativePrivacyManagerViewController.swift
//  ConsentViewController-tvOS
//
//  Created by Vilas on 01/04/21.
//

import UIKit
import Foundation

@objcMembers class SPCCPANativePrivacyManagerViewController: SPNativeScreenViewController, SPNativePrivacyManagerHome {
    weak var delegate: SPNativePMDelegate?

    @IBOutlet weak var categoriesExplainerLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var selectedCategoryTextLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var ourPartners: UIButton!
    @IBOutlet weak var managePreferenceButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var categoryTableView: UITableView!

    @IBOutlet weak var header: SPPMHeader!

    var secondLayerData: GDPRPrivacyManagerViewResponse?

    var categories: [GDPRCategory] { pmData.categories }
    var vendorGrants: SPGDPRVendorGrants?
    let cellReuseIdentifier = "cell"

    var snapshot: CCPAPMConsentSnaptshot?

    override var preferredFocusedView: UIView? { acceptButton }

    func setHeader () {
        header.spBackButton = viewData.byId("CloseButton") as? SPNativeButton
        header.spTitleText = viewData.byId("Header") as? SPNativeText
        header.onBackButtonTapped = { [weak self] in
            if let this = self {
                self?.messageUIDelegate?.action(SPAction(type: .Dismiss), from: this)
            }
        }
    }

    override func loadMessage() {
        loaded(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader()
        loadLabelView(forComponentId: "CategoriesHeader", label: categoriesExplainerLabel)
        loadTextView(forComponentId: "PublisherDescription", textView: descriptionTextView)
        loadButton(forComponentId: "AcceptAllButton", button: acceptButton)
        loadButton(forComponentId: "NavCategoriesButton", button: managePreferenceButton)
        loadButton(forComponentId: "NavVendorsButton", button: ourPartners)
        loadButton(forComponentId: "NavPrivacyPolicyButton", button: privacyPolicyButton)
        loadImage(forComponentId: "LogoImage", imageView: logoImageView)
        categoryTableView.allowsSelection = false
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }

    @IBAction func onAcceptTap(_ sender: Any) {
        action(
            SPAction(type: .AcceptAll, id: nil, campaignType: campaignType),
            from: self
        )
    }

    @IBAction func onManagePreferenceTap(_ sender: Any) {
        guard let secondLayerData = secondLayerData else {
            delegate?.on2ndLayerNavigating(messageId: messageId, campaignType: .ccpa) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.onError(error)
                case .success(let data):
                    if let strongSelf = self {
                        let controller = SPCCPAManagePreferenceViewController(
                            messageId: self?.messageId,
                            campaignType: strongSelf.campaignType,
                            viewData: strongSelf.pmData.categoriesView,
                            pmData: strongSelf.pmData,
                            delegate: self,
                            nibName: "SPCCPAManagePreferenceViewController"
                        )
                        if self?.snapshot == nil {
                            self?.snapshot = CCPAPMConsentSnaptshot(
                                grants: data.grants ?? SPGDPRVendorGrants(),
                                vendors: Set<GDPRVendor>(data.vendors),
                                categories: Set<GDPRCategory>(data.categories),
                                specialPurposes: Set<GDPRCategory>(data.specialPurposes),
                                features: Set<GDPRCategory>(data.features),
                                specialFeatures: Set<GDPRCategory>(data.specialFeatures)
                            )
                        }
                        controller.categories = data.categories
                        controller.consentsSnapshot = strongSelf.snapshot!
                        self?.present(controller, animated: true)
                    }
                }
            }
            return
        }
        let controller = SPCCPAManagePreferenceViewController(
            messageId: messageId,
            campaignType: campaignType,
            viewData: pmData.categoriesView,
            pmData: pmData,
            delegate: self,
            nibName: "SPManagePreferenceViewController"
        )
        if snapshot == nil {
            snapshot = CCPAPMConsentSnaptshot(
                grants: secondLayerData.grants ?? SPGDPRVendorGrants(),
                vendors: Set<GDPRVendor>(secondLayerData.vendors),
                categories: Set<GDPRCategory>(secondLayerData.categories),
                specialPurposes: Set<GDPRCategory>(secondLayerData.specialPurposes),
                features: Set<GDPRCategory>(secondLayerData.features),
                specialFeatures: Set<GDPRCategory>(secondLayerData.specialFeatures)
            )
        }
        controller.categories = secondLayerData.categories
        controller.consentsSnapshot = snapshot!
        present(controller, animated: true)
    }

    @IBAction func onPartnersTap(_ sender: Any) {
        delegate?.on2ndLayerNavigating(messageId: messageId, campaignType: .ccpa) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.onError(error)
            case .success(let data):
                if let strongSelf = self {
                    if self?.snapshot == nil {
                        self?.snapshot = CCPAPMConsentSnaptshot(
                            grants: data.grants ?? SPGDPRVendorGrants(),
                            vendors: Set<GDPRVendor>(data.vendors),
                            categories: Set<GDPRCategory>(data.categories),
                            specialPurposes: Set<GDPRCategory>(data.specialPurposes),
                            features: Set<GDPRCategory>(data.features),
                            specialFeatures: Set<GDPRCategory>(data.specialFeatures)
                        )
                    }
                    let controller = SPCCPAPartnersViewController(
                        messageId: self?.messageId,
                        campaignType: strongSelf.campaignType,
                        viewData: strongSelf.pmData.vendorsView,
                        pmData: strongSelf.pmData,
                        delegate: self,
                        nibName: "SPPartnersViewController"
                    )
                    controller.vendors = data.vendors
                    controller.consentsSnapshot = strongSelf.snapshot!
                    self?.present(controller, animated: true)
                }
            }
        }
    }

    @IBAction func onPrivacyPolicyTap(_ sender: Any) {
        guard let privacyPolicyView = pmData.privacyPolicyView else {
            onError(UnableToFindView(withId: "PrivacyPolicyView"))
            return
        }
        present(SPPrivacyPolicyViewController(
            messageId: messageId,
            campaignType: campaignType,
            viewData: privacyPolicyView,
            pmData: pmData,
            delegate: self,
            nibName: "SPPrivacyPolicyViewController"
        ), animated: true)
    }
}

extension SPCCPANativePrivacyManagerViewController: SPMessageUIDelegate {
    func loaded(_ controller: SPMessageViewController) {
        messageUIDelegate?.loaded(self)
    }

    func action(_ action: SPAction, from controller: SPMessageViewController) {
        dismiss(animated: false) {
            self.messageUIDelegate?.action(action, from: controller)
        }
    }

    func onError(_ error: SPError) {
        messageUIDelegate?.onError(error)
    }

    func finished(_ vcFinished: SPMessageViewController) {}
}

// MARK: UITableViewDataSource
extension SPCCPANativePrivacyManagerViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SPCCPANativePrivacyManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        loadLabelText(
            forComponentId: "CategoriesDescriptionText",
            labelText: categories[indexPath.row].description,
            label: selectedCategoryTextLabel
        )
        return true
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        if context.nextFocusedIndexPath == nil {
            loadLabelText(
                forComponentId: "CategoriesDescriptionText",
                labelText: "",
                label: selectedCategoryTextLabel
            )
        }
        return true
    }
}
