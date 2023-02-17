//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Robert Alec Hovey on 2/16/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), configuration: ConfigurationIntent())
    }

    // used in the selection view
    // if there is a network call, there would need to be a placeholder here
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    // entry is data - in this case it is a date
    // so `entries` is an array of dates
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DayEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        // policy determines when the timeline updates again
        // there exists a `never` option - used in the case when the only time an update occurs is when the user "inputs data"
        // `after` is when you want to specify a specific date
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// always needs a date - it needs to know when to update
struct DayEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct MonthlyWidgetEntryView : View {
    var entry: DayEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.blue.gradient.opacity(0.8))
            
            VStack {
                HStack {
                    Text("❄️")
                    Text(entry.date.formatted(.dateTime.weekday(.wide)))
                }
            }
        }
    }
}

@main
struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        // intentConfiguration is used for customizing (press and hold - edit features)
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            // MonthlyWidgetEntryView(entry: entry)
            VStack {
                Link(destination: URL(string: "calshow://")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .configurationDisplayName("My Widget") // comes up in gallery
        .description("This is an example widget.") // comes up in gallery
    }
}

struct MonthlyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyWidgetEntryView(entry: DayEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
