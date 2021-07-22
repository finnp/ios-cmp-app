//
//  SPVendorDetailsViewController.swift
//  ConsentViewController-tvOS
//
//  Created by Vilas on 11/05/21.
//

import UIKit
import Foundation

class SPVendorDetailsViewController: SPNativeScreenViewController {
    @IBOutlet weak var headerView: SPPMHeader!
    @IBOutlet weak var descriptionTextView: UITextView!
//    @IBOutlet weak var barcodeLabel: UILabel!
//    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    @IBOutlet weak var vendorDetailsTableView: UITableView!
    @IBOutlet weak var actionsContainer: UIStackView!

    weak var vendorManagerDelegate: PMVendorManager?

    let cellReuseIdentifier = "cell"
    var vendor: VendorListVendor?
    var consentCategories: [String] { vendor?.consentCategories.map { $0.name } ?? [] }
    var specialPurposes: [String] { vendor?.iabSpecialPurposes ?? [] }
    var specialFeatures: [String] { vendor?.iabSpecialFeatures ?? [] }
    var sections: [SPNativeText?] {
        var sections: [SPNativeText?] = []
        if consentCategories.isNotEmpty() {
            sections.append(viewData.byId("PurposesText") as? SPNativeText)
        }
        if specialPurposes.isNotEmpty() {
            sections.append(viewData.byId("SpecialPurposes") as? SPNativeText)
        }
        if specialFeatures.isNotEmpty() {
            sections.append(viewData.byId("SpecialFeatures") as? SPNativeText)
        }
        return sections
    }

    func setHeader () {
        headerView.spBackButton = viewData.byId("BackButton") as? SPNativeButton
        headerView.spTitleText = viewData.byId("Header") as? SPNativeText
        headerView.titleLabel.text = vendor?.name
        headerView.onBackButtonTapped = { [weak self] in self?.dismiss(animated: true) }
    }

    override func setFocusGuides() {
        addFocusGuide(from: headerView.backButton, to: actionsContainer, direction: .bottomTop)
        addFocusGuide(from: headerView.backButton, to: vendorDetailsTableView, direction: .right)
        addFocusGuide(from: actionsContainer, to: vendorDetailsTableView, direction: .rightLeft)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader()
        loadTextView(forComponentId: "VendorDescription", textView: descriptionTextView, text: vendor?.description)

//        loadLabelView(forComponentId: "QrInstructions", label: barcodeLabel)
        loadButton(forComponentId: "OnButton", button: onButton)
        loadButton(forComponentId: "OffButton", button: offButton)
        vendorDetailsTableView.allowsSelection = false
        vendorDetailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        vendorDetailsTableView.delegate = self
        vendorDetailsTableView.dataSource = self
    }

    @IBAction func onOnButtonTap(_ sender: Any) {
        if let vendor = vendor {
            vendorManagerDelegate?.onVendorOn(vendor)
        }
        dismiss(animated: true)
    }

    @IBAction func onOffButtonTap(_ sender: Any) {
        if let vendor = vendor {
            vendorManagerDelegate?.onVendorOff(vendor)
        }
        dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource
extension SPVendorDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        label.text = sections[section]?.settings.text
        label.font = UIFont(from: sections[section]?.settings.style?.font)
        label.textColor = UIColor(hexString: sections[section]?.settings.style?.font?.color)
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return consentCategories.count
        } else if section == 1 {
            return specialPurposes.count
        } else if section == 2 {
            return specialFeatures.count
        } else {
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (vendorDetailsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        var cellText = ""
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            cellText = consentCategories[row]
        } else if section == 1 {
            cellText = specialPurposes[row]
        } else if section == 2 {
            cellText = specialFeatures[row]
        }
        cell.textLabel?.text = cellText
        return cell
    }

    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
