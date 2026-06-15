# Export and Import Specification

## 1. Purpose

Define JSON export format and iCloud backup contract for user data portability.

---

## 2. Local JSON Export

### Trigger
Settings → **Export Data** → share sheet

### Payload structure

```json
{
  "version": "1.0",
  "exportedAt": "ISO8601",
  "metrics": [...],
  "entries": [...]
}
```

Metric and entry fields mirror [`DataSchemaSpec.md`](DataSchemaSpec.md). Goals are embedded in metric export (via `iCloudBackupService.BackupMetric.goals`).

### Rules
- Include schema `version` for future import compatibility
- UTF-8 JSON, pretty-printed for human readability
- No encryption in 1.0 (user responsible for share destination)

### Import (1.0)
- **Out of scope** for lean 1.0 unless already working — export-only is minimum bar
- If import added: validate version, merge or replace policy, user confirmation

---

## 3. iCloud Backup

Service: `iCloudBackupService` (CloudKit private database)

| Field | Notes |
|-------|-------|
| Record type | Single backup record per device/user |
| Payload | Same logical schema as JSON export |
| Restore | Settings → Restore from iCloud — replaces local data |

### Rules
- User-initiated only (no background sync)
- Requires iCloud sign-in; graceful error if unavailable
- Restore must confirm destructive overwrite of local data

---

## 4. Testing

- Export produces valid JSON decodable to backup models
- Round-trip: export → parse → counts match
- Restore integration (mock CloudKit or test hooks)

---

## 5. Verification

| Field | Value |
|-------|--------|
| **Estimated release** | `1.0.0` |
| **Last verified** | 2026-06-14 |
| **Commit** | (current) |
| **Code** | `SettingsView.swift`, `iCloudBackupService.swift`, `BackupSheet.swift`, `RestoreSheet.swift` |
