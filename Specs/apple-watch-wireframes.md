# ⌚ Apple Watch UI Wireframes - TrackBoth

## 📱 Main Interface Wireframe

### **Primary Screen Layout (40mm/44mm)**

```
┌─────────────────────────────────┐
│  📅 Today, December 19         │
│                                 │
│  ✅ Habits (2/3)                │
│  ┌─────────────────────────────┐│
│  │ ✓ Exercise                  ││
│  │   🏃‍♂️ 30 min                ││
│  │                             ││
│  │ ○ Read                      ││
│  │   📚 0 pages                ││
│  │                             ││
│  │ ✓ Meditate                  ││
│  │   🧘‍♀️ 10 min                ││
│  │                             ││
│  │ ○ Water                     ││
│  │   💧 0 glasses              ││
│  │                             ││
│  │ ○ Running                  ││
│  │   🏃‍♂️ 0 miles               ││
│  └─────────────────────────────┘│
│                                 │
│  ❌ Vices (1/2)                 │
│  ┌─────────────────────────────┐│
│  │ ✗ Social Media              ││
│  │   📱 0 min                  ││
│  │                             ││
│  │ ○ Smoking                   ││
│  │   🚬 0 times                ││
│  └─────────────────────────────┘│
│                                 │
│  📊 3/5 Complete                │
│  🔥 5 day streak                │
└─────────────────────────────────┘
```

---

## 🎯 Interaction States

### **Habit Toggle States**

**Completed Habit:**
```
┌─────────────────────────────┐
│ ✓ Exercise                  ││
│   🏃‍♂️ 30 min                ││
│   [Completed]               ││
└─────────────────────────────┘
```

**Incomplete Habit:**
```
┌─────────────────────────────┐
│ ○ Read                      ││
│   📚 0 pages                ││
│   [Tap to complete]         ││
└─────────────────────────────┘
```

**Vice Toggle States**

**Avoided Vice:**
```
┌─────────────────────────────┐
│ ✗ Social Media              ││
│   📱 0 min                  ││
│   [Avoided today]           ││
└─────────────────────────────┘
```

**Failed Vice:**
```
┌─────────────────────────────┐
│ ○ Smoking                   ││
│   🚬 2 times                ││
│   [Tap to log]              ││
└─────────────────────────────┘
```

---

## 🔢 Quantity Input Modal

### **Quantity Input Screen**

```
┌─────────────────────────────────┐
│  ← Exercise                     │
│                                 │
│  🏃‍♂️ Exercise                  │
│                                 │
│  How many minutes?              │
│                                 │
│  ┌─────────────────────────────┐│
│  │        30                   ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐        │
│  │  5  │ │ 10  │ │ 15  │        │
│  └─────┘ └─────┘ └─────┘        │
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐        │
│  │ 20  │ │ 30  │ │ 45  │        │
│  └─────┘ └─────┘ └─────┘        │
│                                 │
│  ┌─────┐ ┌─────┐ ┌─────┐        │
│  │ 60  │ │ 90  │ │120  │        │
│  └─────┘ └─────┘ └─────┘        │
│                                 │
│  [Cancel]    [Save]             │
└─────────────────────────────────┘
```

### **Unit Selection Screen**

```
┌─────────────────────────────────┐
│  ← Exercise                     │
│                                 │
│  🏃‍♂️ Exercise                  │
│                                 │
│  Select Unit:                   │
│                                 │
│  ┌─────────────────────────────┐│
│  │ ✓ minutes                   ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ○ hours                     ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ○ times                     ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ○ reps                      ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ○ sets                      ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ○ Custom...                 ││
│  └─────────────────────────────┘│
│                                 │
│  [Cancel]    [Select]           │
└─────────────────────────────────┘
```

### **Custom Unit Input**

```
┌─────────────────────────────────┐
│  ← Exercise                     │
│                                 │
│  🏃‍♂️ Exercise                  │
│                                 │
│  Enter custom unit:              │
│                                 │
│  ┌─────────────────────────────┐│
│  │        miles                ││
│  └─────────────────────────────┘│
│                                 │
│  Examples:                      │
│  • laps                        │
│  • cups                        │
│  • steps                       │
│  • miles                       │
│                                 │
│  [Cancel]    [Save]             │
└─────────────────────────────────┘
```

---

## 🏷️ Custom Unit Support

### **Custom Unit Display**

**Pre-defined Units:**
```
┌─────────────────────────────┐
│ ✓ Exercise                  ││
│   🏃‍♂️ 30 min                ││
└─────────────────────────────┘
```

**Custom Units:**
```
┌─────────────────────────────┐
│ ○ Running                  ││
│   🏃‍♂️ 0 miles               ││
└─────────────────────────────┘
```

**Custom Units with Examples:**
```
┌─────────────────────────────┐
│ ○ Water                     ││
│   💧 0 glasses              ││
└─────────────────────────────┘
```

### **Unit Selection Flow**

**Step 1: Long Press Habit**
```
┌─────────────────────────────┐
│ ○ Running                  ││
│   🏃‍♂️ 0 miles               ││
│   [Long press to edit]      ││
└─────────────────────────────┘
```

**Step 2: Unit Selection**
```
┌─────────────────────────────┐
│ Select Unit:                 ││
│                             ││
│ ✓ miles                     ││
│ ○ laps                      ││
│ ○ steps                     ││
│ ○ Custom...                 ││
└─────────────────────────────┘
```

**Step 3: Custom Unit Input**
```
┌─────────────────────────────┐
│ Enter custom unit:           ││
│                             ││
│ ┌─────────────────────────┐│
│ │        laps             ││
│ └─────────────────────────┘│
│                             ││
│ Examples:                   ││
│ • laps                     ││
│ • cups                     ││
│ • steps                    ││
└─────────────────────────────┘
```

### **Common Custom Units**

**Fitness:**
- laps, miles, steps, reps, sets, rounds

**Nutrition:**
- cups, glasses, servings, ounces, grams

**Time-based:**
- minutes, hours, sessions, rounds

**General:**
- times, items, pieces, units

---

## 📊 Weekly Summary View

### **Weekly Progress Screen**

```
┌─────────────────────────────────┐
│  ← Weekly Summary               │
│                                 │
│  📅 This Week                   │
│                                 │
│  ✅ Habits                      │
│  ┌─────────────────────────────┐│
│  │ Exercise: 5/7 days          ││
│  │ Read: 3/7 days              ││
│  │ Meditate: 7/7 days          ││
│  └─────────────────────────────┘│
│                                 │
│  ❌ Vices                       │
│  ┌─────────────────────────────┐│
│  │ Social Media: 2/7 avoided   ││
│  │ Smoking: 0/7 avoided        ││
│  └─────────────────────────────┘│
│                                 │
│  📊 Overall: 17/21 (81%)       │
│                                 │
│  [Back to Today]                │
└─────────────────────────────────┘
```

---

## 🔥 Streak Display Variations

### **Streak Indicators**

**Active Streak:**
```
┌─────────────────────────────┐
│ ✓ Exercise                  ││
│   🏃‍♂️ 30 min                ││
│   🔥 5 day streak           ││
└─────────────────────────────┘
```

**New Streak:**
```
┌─────────────────────────────┐
│ ✓ Read                      ││
│   📚 20 pages               ││
│   🆕 1 day streak           ││
└─────────────────────────────┘
```

**Broken Streak:**
```
┌─────────────────────────────┐
│ ○ Meditate                  ││
│   🧘‍♀️ 0 min                 ││
│   💔 Streak broken          ││
└─────────────────────────────┘
```

---

## 🎨 Visual Design Elements

### **Color Coding**

**Habits (Positive):**
- ✅ Checkmark: Green (#34C759)
- 🏃‍♂️ Icon: Green accent
- Background: Dark green tint

**Vices (Negative):**
- ✗ Cross: Red (#FF3B30)
- 🚬 Icon: Red accent
- Background: Dark red tint

**Neutral Elements:**
- ○ Circle: Gray (#8E8E93)
- Text: White (#FFFFFF)
- Background: Black (#000000)

### **Typography Hierarchy**

**Headers:**
- Date: 16pt, Bold
- Section titles: 14pt, Semibold

**Content:**
- Habit names: 13pt, Regular
- Quantities: 11pt, Regular
- Status text: 10pt, Regular

**Buttons:**
- Action text: 12pt, Semibold
- Number buttons: 16pt, Bold

---

## 📱 Screen Size Adaptations

### **40mm Watch (Small)**

```
┌─────────────────────────┐
│ 📅 Dec 19              │
│                         │
│ ✅ Habits (2/3)         │
│ ┌─────────────────────┐ │
│ │ ✓ Exercise          │ │
│ │ ○ Read              │ │
│ │ ✓ Meditate          │ │
│ └─────────────────────┘ │
│                         │
│ ❌ Vices (1/2)          │
│ ┌─────────────────────┐ │
│ │ ✗ Social Media      │ │
│ │ ○ Smoking           │ │
│ └─────────────────────┘ │
│                         │
│ 📊 3/5 Complete         │
└─────────────────────────┘
```

### **44mm Watch (Large)**

```
┌─────────────────────────────────┐
│  📅 Today, December 19         │
│                                 │
│  ✅ Habits (2/3)                │
│  ┌─────────────────────────────┐│
│  │ ✓ Exercise                  ││
│  │   🏃‍♂️ 30 min                ││
│  │                             ││
│  │ ○ Read                      ││
│  │   📚 0 pages                ││
│  │                             ││
│  │ ✓ Meditate                  ││
│  │   🧘‍♀️ 10 min                ││
│  └─────────────────────────────┘│
│                                 │
│  ❌ Vices (1/2)                 │
│  ┌─────────────────────────────┐│
│  │ ✗ Social Media              ││
│  │   📱 0 min                  ││
│  │                             ││
│  │ ○ Smoking                   ││
│  │   🚬 0 times                ││
│  └─────────────────────────────┘│
│                                 │
│  📊 3/5 Complete                │
│  🔥 5 day streak                │
└─────────────────────────────────┘
```

---

## 🎯 Interaction Patterns

### **Tap Interactions**

**Single Tap:**
- Toggle habit/vice completion
- Navigate to quantity input
- Return to main screen

**Long Press:**
- Show quantity input modal
- Access weekly summary
- Voice input activation

**Crown Scroll:**
- Navigate through long lists
- Adjust quantity values
- Scroll through weekly data

### **Haptic Feedback**

**Success Haptic:**
- Habit completed: Success pattern
- Vice avoided: Success pattern
- Quantity saved: Success pattern

**Error Haptic:**
- Invalid input: Error pattern
- Sync failure: Warning pattern
- Network error: Warning pattern

---

## 🚀 Loading States

### **Initial Load**

```
┌─────────────────────────────────┐
│  📅 Today, December 19         │
│                                 │
│  ⏳ Loading habits...           │
│                                 │
│  ┌─────────────────────────────┐│
│  │                             ││
│  │        [Spinner]             ││
│  │                             ││
│  └─────────────────────────────┘│
│                                 │
│  📊 Syncing with iPhone...      │
└─────────────────────────────────┘
```

### **Sync Error**

```
┌─────────────────────────────────┐
│  📅 Today, December 19         │
│                                 │
│  ⚠️ Sync Error                  │
│                                 │
│  Unable to sync with iPhone.   │
│  Data may be outdated.          │
│                                 │
│  [Retry] [Continue Offline]     │
└─────────────────────────────────┘
```

---

## 🎨 Accessibility Considerations

### **VoiceOver Support**

**Habit Row:**
- "Exercise, completed, 30 minutes, 5 day streak"
- "Read, not completed, 0 pages, tap to complete"

**Vice Row:**
- "Social Media, avoided today, 0 minutes, 3 day streak"
- "Smoking, not avoided, 2 times, tap to log"

### **Large Text Support**

**Dynamic Type Scaling:**
- Headers: Scales up to 20pt
- Content: Scales up to 16pt
- Buttons: Scales up to 18pt
- Maintains readability at all sizes

---

## 🔧 Technical Implementation Notes

### **Layout Constraints**

**Main Screen:**
- Top margin: 8pt
- Section spacing: 12pt
- Row height: 44pt minimum
- Touch target: 44pt minimum

**Quantity Modal:**
- Modal height: 80% of screen
- Button grid: 3x3 layout
- Button size: 60pt x 40pt
- Margin: 16pt

### **Performance Considerations**

**Data Loading:**
- Lazy load metrics
- Cache today's entries
- Background sync only
- Minimal memory usage

**Animations:**
- 0.3s duration for state changes
- Spring animations for modals
- Haptic feedback timing
- Smooth scrolling

---

*These wireframes provide a comprehensive visual guide for implementing the Apple Watch companion app, emphasizing simplicity, clarity, and immediate usability.*
