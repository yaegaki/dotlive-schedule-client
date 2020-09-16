//
//  awaisensei2.swift
//  awaisensei2
//
//  Created by yaegaki on 2020/09/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), info: Provider.getCacheOrPlaceholderInfo(), family: context.family)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, info: Provider.getCacheOrPlaceholderInfo(), family: context.family)
        completion(entry)
    }
    
    static func getCacheOrPlaceholderInfo() -> ScheduleInfo {
        if let info = ScheduleManager.getCache() {
            return info
        }
        
        return ScheduleInfo(createAt: Date(), tweetId: "placeholder", title: "🐢9/15(火)どっとライブ予定表🐢", imageData: Data(), image: UIImage(named: "awaisensei-placeholder")!)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        ScheduleManager.getScheduleInfo(handler: { info in
            let timeline = createTimeline(configuration: configuration, family: context.family, info: info)
            completion(timeline)
        })
    }
    
    private func createTimeline(configuration: ConfigurationIntent, family: WidgetFamily, info: ScheduleInfo?) -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        return Timeline(entries: [SimpleEntry(date: currentDate, configuration: configuration, info: info, family: family)], policy: .after(refreshDate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let info: ScheduleInfo?
    let family: WidgetFamily
}

struct awaisensei2EntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            if let info = entry.info {
                getInfoView(info: info)
            } else {
                getFailedView()
            }
        }.padding()
    }
    
    func getFailedView() -> some View {
        VStack {
            HStack {
                Text("読み込めませんでした")
                    .foregroundColor(.white)
                    .font(.title3)
                Spacer()
            }.padding(.vertical, 10)
            Spacer()
        }
    }
    
    func getInfoView(info: ScheduleInfo) -> some View {
        Group {
            if entry.family == .systemMedium {
                Image(uiImage: info.image)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(spacing:0) {
                    HStack {
                        Text(info.title)
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                    }.padding(.vertical, 10)
                    Image(uiImage: info.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        
    }
}

@main
struct awaisensei2: Widget {
    let kind: String = "jp.yaegaki.dotlive-schedule.awaisensei2"
    static let gradient = LinearGradient.init(gradient: Gradient(colors: [Color.init(red: 0x39/255, green: 0xbb/255, blue: 0xff/255), Color.init(red: 0x1b/255, green: 0x9e/255, blue: 0xff/255)]), startPoint: .top, endPoint: .bottom)
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            awaisensei2EntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(awaisensei2.gradient)
        }
        .configurationDisplayName("どっとライブ予定表@竜崎あわい先生")
        .description("竜崎あわい先生の最新のどっとライブ予定表を表示します。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct awaisensei2_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            getView(family: .systemMedium)
            getView(family: .systemLarge)
        }
    }
    
    static func getView(family: WidgetFamily) -> some View {
        awaisensei2EntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), info: Provider.getCacheOrPlaceholderInfo(), family: family))
            .previewContext(WidgetPreviewContext(family:family))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(awaisensei2.gradient)
    }
}
