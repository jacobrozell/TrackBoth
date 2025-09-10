📱 Boolean Habit Tracker App

⸻

✨ Core Concept

Track custom yes/no (Boolean) habits on a daily basis. Visualize progress over time with charts, streaks, and monthly/yearly goals.

⸻

🧩 Core Features
	•	✅ Custom Metrics (user-defined)
	•	✅ Daily Logging (yes/no toggle)
	•	✅ Data Storage (SwiftData/Core Data)
	•	✅ Visualizations (Swift Charts)

⸻

🗂 Data Model

Metric
	•	id (UUID)
	•	name (String)
	•	createdAt (Date)

MetricEntry
	•	id (UUID)
	•	metricID (UUID)
	•	date (Date)
	•	value (Bool)

Goal
	•	id (UUID)
	•	metricID (UUID)
	•	period (monthly / yearly)
	•	target (# of true days)

⸻

🎯 Goal Tracking
	•	Link a goal to a metric.
	•	Track completion within the current month/year.
	•	Compare actual ✅ days to target.
	•	Show progress as a percentage or progress bar.

⸻

📱 UI Structure (SwiftUI)
	•	Home Screen → list of metrics with today’s toggles.
	•	History View → calendar or list of past entries.
	•	Goals View → cards with progress bars.
	•	Charts View → bar, line, heatmap, streaks.

⸻

📊 Visualization Ideas
	•	📈 Line chart → adherence trends.
	•	📊 Bar chart → completion per week/month.
	•	🟩 Heatmap → calendar-style success/failure.
	•	🔥 Streak tracker → current & longest streak.
	•	🎯 Goal progress bar → monthly/yearly completion.

⸻

🚀 Stretch Features
	•	⏰ Notifications/reminders
	•	🖼 Widgets (quick check-ins)
	•	⌚ Apple Watch companion app
	•	☁️ iCloud sync
	•	📤 Export/import data (CSV/JSON)
	•	🏆 Achievement badges
	•	📊 Compare this year vs last year

⸻

🛠 Tech Stack
	•	SwiftUI → UI
	•	SwiftData / Core Data → persistence
	•	Swift Charts → visualizations
	•	AppStorage / UserDefaults → lightweight settings
	•	UserNotifications → reminders