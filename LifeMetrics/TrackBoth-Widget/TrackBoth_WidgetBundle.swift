//
//  TrackBoth_WidgetBundle.swift
//  TrackBoth-Widget
//
//  Created by Jacob Rozell on 9/15/25.
//

import WidgetKit
import SwiftUI

@main
struct TrackBoth_WidgetBundle: WidgetBundle {
    var body: some Widget {
        TrackBoth_Widget()
        TrackBoth_WidgetControl()
        TrackBoth_WidgetLiveActivity()
    }
}
