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
        let cache = ScheduleManager.getCache()
        if let cache = cache {
            updateUI(info: cache)
        }
        
        ScheduleManager.getScheduleInfo() { info in
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
                completionHandler(.newData)
            }
        }
    }
    
    func updateUI(info: ScheduleInfo) {
        self.label.text = info.title
        self.scheduleImageView.image = info.image
    }
}
