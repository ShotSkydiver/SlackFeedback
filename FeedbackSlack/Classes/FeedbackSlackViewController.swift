//
//  FeedbackSlackViewController.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit
import CoreTelephony

class FeedbackSlackViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var defaultTopConstraint: CGFloat!
    @IBOutlet weak var closeButton: UIButton!
    var image: UIImage? {
        didSet {
            if self.isViewLoaded {
                self.imageView.image = image
            }
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subjectField: FSSelectionField!
    @IBOutlet weak var commentView: FSTextView!
    @IBOutlet weak var indicatorView: UIView!

    lazy var transition: FS_Transition = FS_Transition()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultTopConstraint = self.topConstraint.constant
        self.imageView.image = self.image

        if let subjects: [String] = FeedbackSlack.shared?.subjects {
            self.subjectField.items = subjects
        } else if let path: String = Bundle(for: type(of: self)).path(forResource: "FeedbackSlack", ofType: "plist"),
            let items: [String] = NSDictionary(contentsOfFile: path)?.object(forKey: "subjects") as? [String] {
            self.subjectField.items = items
        }

        self.commentView.layer.borderWidth = 1.0
        self.commentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        self.commentView.layer.cornerRadius = 3.0

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapGestureRecognizer(_:)))
        self.imageView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func closeButtonDidTapped(_ sender: AnyObject) {
        FeedbackSlack.shared?.close()
    }

    @IBAction func feedbackButtonDidTapped(_ sender: AnyObject) {
        self.commentView.resignFirstResponder()

        let carrier: String = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? ""
        let reachability: Reachability = Reachability()!

        guard let subject: String = self.subjectField.selectedValue,
        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
        let build: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String,
        let language: String = NSLocale.current.languageCode,
        let country: String = NSLocale.current.regionCode
        else {
            return
        }

        let comment: String = self.commentView.text ?? ""
        let border: String = "------------------------"

        var posts: [[String]] = [
            ["Feedback Type", subject],
            ["Comments", comment],
            [border],
            ["App", appName],
            ["Version", version],
            ["Build", build],
            ["Device Name", UIDevice.current.name],
            ["Device Model", UIDevice.current.model],
            ["Platform", UIDevice.current.systemName],
            ["iOS Version", UIDevice.current.systemVersion],
            ["Language", language],
            ["Country", country],
            ["Network Type", reachability.currentReachabilityStatus.description],
            ["Carrier", carrier]
        ]

        if let options = FeedbackSlack.shared?.options {
            posts += [
                [border],
                ["Options", options]
            ]
        }

        let post: String = posts.map { (post: [String]) -> String in
            post.joined(separator: ": ")
            }.joined(separator: "\n")
        self.postSlack(post)
    }

    private func postSlack(_ comment: String) {
        guard let slack: FeedbackSlack = FeedbackSlack.shared,
            let image: UIImage = self.image,
            let data: Data = image.pngData(),
            let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            else {
            return
        }

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date: String = dateFormatter.string(from: Date())

        let fileUpload: FileUpload = FileUpload(token: slack.slackToken, data: data, filename: "\(Date().timeIntervalSince1970).png", contentType: "image/png", title: "\(appName) feedback \(date)", initialComment: comment, channels: [slack.slackChannel])

        self.indicatorView.isHidden = false
        let configration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configration)
        let task: URLSessionTask = session.dataTask(with: fileUpload.request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        guard let json: [String: AnyObject] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                            fatalError("json serialization failed")
                        }
                        if json["ok"] as? Int == 1 {
                            FeedbackSlack.shared?.close()
                        }
                    } catch {
                        print("json serialization failed")
                    }

                } else if let error = error {
                    print("error:\(error)")
                }
                
                self?.indicatorView.isHidden = true
            }
        }
        task.resume()
    }
}

extension FeedbackSlackViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        let duration: TimeInterval = (notification as NSNotification).userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.33
        let keyboardFrame: CGRect = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        self.view.layoutIfNeeded()
        self.topConstraint.constant = self.defaultTopConstraint - keyboardFrame.size.height
        UIView.animate(withDuration: duration) { [unowned self] in
            self.view.setNeedsLayout()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let duration: TimeInterval = (notification as NSNotification).userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.33
        self.view.layoutIfNeeded()
        self.topConstraint.constant = self.defaultTopConstraint
        UIView.animate(withDuration: duration) { [unowned self] in
            self.view.setNeedsLayout()
        }
    }
}

extension FeedbackSlackViewController {
    @objc func imageViewTapGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        let previewViewController: FeedbackPreviewViewController = FeedbackPreviewViewController.instantitate()
        previewViewController.image = self.image

        self.transition.presentDelegate = self
        self.transition.dismissDelegate = previewViewController
        previewViewController.transitioningDelegate = self.transition
        previewViewController.modalPresentationStyle = UIModalPresentationStyle.custom

        self.present(previewViewController, animated: true, completion: nil)
    }
}

extension FeedbackSlackViewController: FS_TransitionDelegate {
    func transitionRect(_ transition: FS_Transition) -> CGRect {
        self.imageView.layoutIfNeeded()
        return self.imageView.convert(self.imageView.bounds, to: nil)
    }

    func transitionImage(_ transition: FS_Transition) -> UIImage? {
        return self.image
    }
}

extension FeedbackSlackViewController: FS_StoryboardInstantiatable {
    static var storyboardName: String {
        return "FeedbackSlackViewController"
    }
    static var storyboardIdentifier: String {
        return "feedbackSlackViewController"
    }
}
