//
//  TodayViewController.swift
//  awaisensei
//
//  Created by yaegaki on 2020/09/09.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var scheduleImageView: UIImageView!
    
    struct ScheduleInfo {
        let tweetId: String
        let title: String
        let imageData: Data
        let image: UIImage
    }
    
    struct SimpleScheduleInfo: Codable {
        let tweetId: String
        let title: String
        let imageURL: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // "表示を増やす"に対応
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded;
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            self.preferredContentSize = maxSize;
        } else {
            // 表示を増やしている時のサイズ
            self.preferredContentSize = CGSize(width: 0, height: 300)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let cache = getCache()
        if let cache = cache {
            updateUI(info: cache)
        }
        
        getScheduleInfo() { info in
            DispatchQueue.main.async {
                guard let newInfo = info else {
                    completionHandler(.failed)
                    return
                }
                
                if let cache = cache, cache.tweetId == newInfo.tweetId {
                    completionHandler(.noData)
                    return
                }
                
                self.updateUI(info: newInfo)
                self.updateCache(info: newInfo)
                completionHandler(.newData)
            }
        }
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateUI(info: ScheduleInfo) {
        self.label.text = info.title
        self.scheduleImageView.image = info.image
    }
    
    let cacheTweetIdKey = "schedule-tweet-id"
    let cacheTitleKey = "schedule-title"
    let cacheImageKey = "schedule-image"
    
    func getCache() -> ScheduleInfo? {
        guard let tweetId = UserDefaults.standard.string(forKey: cacheTweetIdKey),
            let title = UserDefaults.standard.string(forKey: cacheTitleKey),
            let imageData = UserDefaults.standard.data(forKey: cacheImageKey) else {
                return nil
        }
        
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        return ScheduleInfo(tweetId: tweetId, title: title, imageData: imageData, image: image)
    }
    
    func updateCache(info: ScheduleInfo) {
        UserDefaults.standard.set(info.tweetId, forKey: cacheTweetIdKey)
        UserDefaults.standard.set(info.title, forKey: cacheTitleKey)
        UserDefaults.standard.set(info.imageData, forKey: cacheImageKey)
    }
    
    func getScheduleInfo(handler: @escaping (ScheduleInfo?) -> Void) {
        let url = URL(string: "https://dotlive-schedule.appspot.com/api/awaisensei")!
        URLSession.shared.dataTask(with: url) { data, res, err in
            if let data = data {
                do {
                    let info: SimpleScheduleInfo = try JSONDecoder().decode(SimpleScheduleInfo.self, from: data)
                    
                    if let url = URL(string: info.imageURL) {
                        self.getImageData(url: url) { imageData in
                            if let imageData = imageData, let image = UIImage(data: imageData) {
                                handler(ScheduleInfo(tweetId: info.tweetId, title: info.title, imageData: imageData, image: image))
                            } else {
                                handler(nil)
                            }
                        }
                        return
                    }
                } catch {
                }
            }
            handler(nil)
            
        }.resume()
    }
    
    func getImageData(url: URL, handler: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, res, err in
            handler(data)
        }.resume()
    }
}
