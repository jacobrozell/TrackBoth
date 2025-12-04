# 📋 TrackBoth - Planned Improvements TODO List

**Created:** December 19, 2024  
**Last Updated:** December 19, 2024 (Refactoring Complete)  
**Source:** Combined from `updated-specs.md` and `motivation-game-spec.md`

---

## 🎨 Settings & Customization Features

- [ ] 💝 **Donate Button**: Support development with in-app donations
- [x ] 📊 **Export Graphs**: Save charts as images (PNG/PDF)
- [x ] 📤 **Share App**: Native iOS sharing for app promotion
- [ x] 📱 **Backup & Restore**: iCloud backup with restore functionality
- [ x] 🎨 **Light/Dark Mode**: Add light/dark mode toggle in settings
- [ ] 🎨 **Custom App Icons**: Add custom app icons selection in settings

---

## 🚀 Core App Enhancements

- [ ] ⏰ **Smart Notifications**: Implement smart notifications with context-aware reminders
- [ ] 🖼 **Home Screen Widgets**: Add home screen widgets for quick daily check-ins
- [ ] ⌚ **Apple Watch App**: Create Apple Watch companion app for quick logging
- [x ] ☁️ **iCloud Sync**: Implement iCloud sync for cross-device data synchronization
- [ ] 🏆 **Achievement System**: Add achievement system with badges for milestones
- [ ] 📊 **Advanced Analytics**: Implement advanced analytics with year-over-year comparisons
- [ x] 🎨 **Theme Customization**: Add theme customization with color schemes and visual themes
- [ ] 📈 **Predictive Analytics**: Add predictive analytics for success probability based on patterns
- [ ] 📱 **Shortcuts Integration**: Add Shortcuts integration for Siri voice logging
- [ ] 🔔 **Smart Reminders**: Implement smart reminders with ML-based optimal timing
- [ ] 🔐 **Privacy Controls**: Add privacy controls with granular data sharing permissions


---

## ✅ Widget Functions - COMPLETED
- ✅ clearAllData(context: ModelContext) - Fixed in iCloudBackupService.swift
- ✅ calculateGoalProgress - Fixed in WidgetIntegration.swift (now uses actual entry data from context)

## ✅ Recent UI Improvements - COMPLETED
- ✅ **Home View Empty State**: Enhanced empty state with "Add Your First Habit" button (matches Goals UI design)

## 🎮 Motivation Game System

- [ ] 🎮 **Scroll Distance Tracking**: Implement scroll distance tracking system for motivation feed
- [ ] 💰 **Scroll Points Currency**: Add scroll points currency system with earning mechanics
- [ ] 📱 **Infinite Scroll Feed**: Create infinite scroll motivation feed with mixed content types
- [ ] 📝 **Content Generation System**: Implement content generation system (personal, curated, educational, inspirational)
- [ ] 🛍 **Cosmetic Upgrade Shop**: Create cosmetic upgrade shop with scroll points currency
- [ ] 💾 **Save to Habit/Vice**: Add save motivation to habit/vice functionality
- [ ] 🔄 **Content Mixing Algorithm**: Implement content mixing algorithm (40% personal, 25% curated, 20% educational, 15% inspirational)
- [ ] 📚 **Curated Database**: Create curated motivational quotes database (100+ quotes)
- [ ] 🎓 **Educational Content**: Add educational content about habit formation psychology (50+ tips)
- [ ] 🖼 **Inspirational Templates**: Create inspirational image templates with text overlays (25+ templates)
- [ ] 📊 **Scroll Analytics**: Add scroll distance analytics and engagement tracking
- [ ] 🧠 **Critical Thinking Posts**: Add critical thinking posts and reporting system (future enhancement)
- [ ] 🏆 **GameCenter Integration**: Add GameCenter leaderboard for scroll distance

---

## ⚡ Technical Improvements (Future Enhancements)

- [ ] ⚡ **Performance Optimizations**: Implement performance optimizations for charts and data queries
- [ ] ♿ **Accessibility Improvements**: Enhance accessibility features and VoiceOver support
- [ ] 📈 **Advanced Chart Visualizations**: Add advanced chart visualizations and new chart types

---

## 🧹 Code Cleanup & Refactoring

- [x] 📁 **Component Separation**: Separate components into individual files for better organization
- [x] 🏗️ **View Models**: Create view models to separate view logic from UI components
- [x] 📝 **MARK Comments**: Add consistent MARK comments for better code navigation
- [x] 🎨 **Code Style Consistency**: Implement consistent code style across all files
- [x] 🔄 **Remove Code Duplication**: Create reusable ViewModifiers and components
- [x] 🧩 **Reusable Components**: Extract common UI patterns into reusable components
- [x] 📦 **File Organization**: Reorganize files into logical folders (Views, ViewModels, Models, Utils)
- [x] 🏷️ **Type Safety**: Improve type safety and reduce force unwrapping
- [x] 🧪 **Code Documentation**: Add comprehensive documentation and comments
- [x] 🔍 **Code Review**: Review and optimize existing code for best practices

---

## 📊 Progress Tracking

**Total Items:** 42  
**Completed:** 12  
**In Progress:** 0  
**Pending:** 30

## 🎯 Priority Recommendations

### Phase 1 (Next 2-4 weeks) - High Impact
- [ ] 🖼 **Home Screen Widgets**: Add home screen widgets for quick daily check-ins
- [ ] ⏰ **Smart Notifications**: Implement smart notifications with context-aware reminders
- [ ] 🏆 **Achievement System**: Add achievement system with badges for milestones

### Phase 2 (1-2 months) - Medium Impact
- [ ] ⌚ **Apple Watch App**: Create Apple Watch companion app for quick logging
- [ ] 📊 **Advanced Analytics**: Implement advanced analytics with year-over-year comparisons
- [ ] 📱 **Shortcuts Integration**: Add Shortcuts integration for Siri voice logging

### Phase 3 (Future) - Complex Features
- [ ] 🎮 **Motivation Game System**: Complete scroll-based motivation system
- [ ] 📈 **Predictive Analytics**: Add predictive analytics for success probability

---

*This TODO list represents all planned improvements from the TrackBoth app specifications. Items are organized by category and include emoji indicators for easy identification.*


* Lets remove Bi-weekly as an option
* Vices card cant have the same check toggle UI. We need an Avoided label


Bugs found during testing:
* Vices are showing 1/1 today after creation
* If I go to yesterday and toggle, I see 365 days clean / 365 day streak which isnt correct since all the Metrics before should have hasBeenLogged as false.