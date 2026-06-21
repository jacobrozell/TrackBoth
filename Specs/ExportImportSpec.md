# Export and Import Specification

## 1. Purpose

Define JSON export/import format for user data portability. Cross-device sync is out of scope for 1.0 (local-only SwiftData).

**Pre-release baseline:** [`docs/release/1.0.0-schema-baseline.md`](../docs/release/1.0.0-schema-baseline.md)

---

## 2. Local JSON Export

### Trigger
Settings → **Export Data** → share sheet

### Payload structure (schema v4)

```json
{
  "schemaVersion": 4,
  "exportDate": "ISO8601",
  "metrics": [...],
  "entries": [...],
  "goals": [...]
}
```

- **metrics** — id, name, habitType, costPerUnit, primaryMotivation, hasBeenLogged
- **entries** — id, metricID, date, value, quantity, unit, mood, etc.
- **goals** — id, metricID, goalType, period, target, quantity fields (v4+)

Schema versions 1–3 import without goals; v4 round-trips goals.

### Rules
- Include `schemaVersion` for import compatibility
- UTF-8 JSON
- No encryption in 1.0 (user responsible for share destination)

### Import
Settings → **Import Data** — destructive replace-all after confirmation.

---

## 3. Testing

- Export produces valid JSON decodable to `TrackBothExport.Payload`
- Round-trip: export → import → counts match (metrics, entries, goals)
- Legacy v1–v3 exports still import

---

## 4. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-15 |
| **Commit** | (current) |
| **Code** | `TrackBothExport.swift`, `ExportImportService.swift`, `SettingsView.swift` |
