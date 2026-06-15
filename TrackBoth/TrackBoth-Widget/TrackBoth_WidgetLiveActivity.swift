//
//  TrackBoth_WidgetLiveActivity.swift
//  TrackBoth-Widget
//
//  Created by Jacob Rozell on 9/15/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TrackBoth_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TrackBoth_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackBoth_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TrackBoth_WidgetAttributes {
    fileprivate static var preview: TrackBoth_WidgetAttributes {
        TrackBoth_WidgetAttributes(name: "World")
    }
}

extension TrackBoth_WidgetAttributes.ContentState {
    fileprivate static var smiley: TrackBoth_WidgetAttributes.ContentState {
        TrackBoth_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TrackBoth_WidgetAttributes.ContentState {
         TrackBoth_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TrackBoth_WidgetAttributes.preview) {
   TrackBoth_WidgetLiveActivity()
} contentStates: {
    TrackBoth_WidgetAttributes.ContentState.smiley
    TrackBoth_WidgetAttributes.ContentState.starEyes
}
