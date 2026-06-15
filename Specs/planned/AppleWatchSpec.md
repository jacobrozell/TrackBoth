**Estimated release:** `1.2`

# Apple Watch Companion Specification

## 1. Purpose

Define watchOS companion for quick habit/vice logging.

**Status:** Planned — **cut from lean 1.0.0**. Orphaned UI exists with no watchOS target.

---

## 2. Scope (when implemented)

- Today's habits/vices list
- Tap to log done / avoided
- Weekly summary glance
- WatchConnectivity sync with iPhone

---

## 3. Current codebase

| File | Lines | Status |
|------|-------|--------|
| `Views/WatchViews/WatchMainView.swift` | ~265 | Not compiled |
| `Views/WatchViews/WatchQuantityInputView.swift` | ~184 | Not compiled |
| Other Watch views | ~600 | Not compiled |

**1.0 action:** Archive to `Archive/Watch/` or delete from main target.

Legacy: [`Specs/apple-watch-spec.md`](../../Specs/apple-watch-spec.md), [`Specs/apple-watch-wireframes.md`](../../Specs/apple-watch-wireframes.md)

---

## 4. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.2` |
| **Last verified** | 2026-06-14 |
| **Commit** | (not started) |
| **Code** | `Views/WatchViews/` |
