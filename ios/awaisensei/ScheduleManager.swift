//
//  ScheduleManager.swift
//  awaisensei
//
//  Created by yaegaki on 2020/09/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//


import UIKit

struct ScheduleInfo {
    let createAt: Date
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

class ScheduleManager {
    static let cacheTweetIdKey = "schedule-tweet-id"
    static let cacheTitleKey = "schedule-title"
    static let cacheImageKey = "schedule-image"
    static let cacheCreateAtKey = "schedule-createAt"
    
    static func getCache() -> ScheduleInfo? {
        guard let tweetId = UserDefaults.standard.string(forKey: self.cacheTweetIdKey),
              let title = UserDefaults.standard.string(forKey: self.cacheTitleKey),
              let imageData = UserDefaults.standard.data(forKey: self.cacheImageKey),
              let createAt = UserDefaults.standard.object(forKey: self.cacheCreateAtKey) as? Date
        else
        {
            return nil
        }
        
        
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        return ScheduleInfo(createAt: createAt, tweetId: tweetId, title: title, imageData: imageData, image: image)
    }
    
    private static func updateCache(info: ScheduleInfo) {
        UserDefaults.standard.set(info.createAt, forKey: cacheCreateAtKey)
        UserDefaults.standard.set(info.tweetId, forKey: cacheTweetIdKey)
        UserDefaults.standard.set(info.title, forKey: cacheTitleKey)
        UserDefaults.standard.set(info.imageData, forKey: cacheImageKey)
    }
    
    static func getScheduleInfo(handler: @escaping (ScheduleInfo?) -> Void) {
        let url = URL(string: "https://dotlive-schedule.appspot.com/api/awaisensei")!
        URLSession.shared.dataTask(with: url) { _data, res, err in
            let cache = getCache()
            guard let data = _data else {
                handler(cache)
                return
            }
            
            var tempInfo: SimpleScheduleInfo? = nil
            do {
                tempInfo = try JSONDecoder().decode(SimpleScheduleInfo.self, from: data)
            } catch {
            }
            
            guard let info = tempInfo, let url = URL(string: info.imageURL) else {
                handler(cache)
                return
            }
            
            if let cache = cache, cache.tweetId == info.tweetId {
                handler(cache)
                return
            }
            
            self.getImageData(url: url) { imageData in
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    let newInfo = ScheduleInfo(createAt: Date(),tweetId: info.tweetId, title: info.title, imageData: imageData, image: image)
                    updateCache(info: newInfo)
                    handler(newInfo)
                } else {
                    handler(cache)
                }
            }
        }.resume()
    }
    
    private static func getImageData(url: URL, handler: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, res, err in
            handler(data)
        }.resume()
    }
}
