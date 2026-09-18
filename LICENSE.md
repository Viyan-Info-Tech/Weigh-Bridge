# Viyan Weighbridge - Licensing System Documentation

## Integration Summary

The licensing system has been integrated as a cross-cutting core service that gates application startup. It does NOT modify existing business logic, database schemas, or authentication flow.

## Where Licensing Was Integrated

### `lib/main.dart`
Replaced direct `WeighbridgeApp` launch with `LicenseGate` which validates the license before showing the application.

### `lib/app/di/injection.dart`
Added `LicenseService` to the dependency injection system.

### New: `lib/core/licensing/`
All licensing code lives in a dedicated core module, isolated from business features.

## Integration Points

```
Application Startup
       |
       v
LicenseGate.validate()
       |
       +---- VALID ──► WeighbridgeApp (with auth routing)
       |
       +---- INVALID/ABSENT ──► LicenseActivationScreen
                                (user imports license.dat)
```

## What Was NOT Modified

- Existing auth flow (login/registration) - unchanged
- Drift database schema - unchanged
- All business features (bill, party, vehicle, material, settings, report) - unchanged
- Existing routing - unchanged (license gate wraps before auth routing)

## What Was Added

### Core Domain
- `License` entity
- `LicenseStatus` enum (8 states)
- `LicenseValidator` abstract + implementation
- Ed25519 signing/verification (via `ed25519_edwards` package)

### Data Layer
- `LicenseLocalDataSource` - manages `license.dat` file
- `ClockRollbackDatasource` - manages `license_state.dat` file
- `MachineIdentityDatasource` - abstract + Windows implementation
- `LicenseModel` - JSON serialization + signature verification

### Services
- `LicenseService` (abstract + `LicenseServiceImpl`)
- `MachineIdentityService` - combines multiple identifiers → SHA-256 hash

### Presentation
- `LicenseActivationScreen` - professional activation UI with:
  - Machine ID display with copy button
  - License file picker (`license.dat`)
  - Activation with status feedback
  - Error messages per failure type

### Windows Native Code
- `machine_identity_handler.h/cpp` - method channel handler that reads:
  - Machine GUID from registry
  - Windows Product ID from registry
  - Processor ID from WMI
  - BaseBoard serial from WMI

## Testing Results

All 23 unit tests pass covering:
- Valid license validation
- Wrong machine detection
- Expired license detection
- Tampered expiry detection (INVALID_SIGNATURE)
- Tampered machine hash detection (INVALID_SIGNATURE)
- Wrong product detection
- Malformed license detection
- Clock rollback detection
- Clock tolerance validation
- Ed25519 cryptographic operations
- Machine identity hash computation
- License model parsing and verification

## Security Architecture

```
ViyanInfo License Authority
        |
        | PRIVATE SIGNING KEY (NEVER shipped)
        |
        v
Signed license.dat
        |
        v
Viyan Weighbridge App
        |
        | PUBLIC VERIFICATION KEY
        |
        v
Verify Signature
```

Private key: Only exists in the License Generator (internal tool).
Public key: Hardcoded in `lib/core/licensing/data/constants/keys.dart`.

## Machine Fingerprint Sources

Multiple Windows identifiers combined and SHA-256 hashed:
1. Machine GUID (registry)
2. Processor ID (WMI)
3. BaseBoard serial (WMI)
4. Windows Product ID (registry)

## Clock Rollback Detection

- Stores `lastKnownValidTime` in `license_state.dat`
- If current time is >5 minutes before last known time: rollback detected
- 5-minute tolerance prevents false positives from normal clock adjustments
- Protected state file (not in SharedPreferences)

## File Protection

- `license.dat` - Importable license file (user-managed)
- `license_state.dat` - Protected internal state (NOT in SharedPreferences)
- Both stored in application support directory

## Database Independence

Licensing authorization is COMPLETELY separate from the Drift/SQLite database.
Copying `weighbridge.sqlite` to another machine does NOT bypass licensing.
The license check uses machine hash binding, not database state.

## Application Updates

Licensing survives normal application updates (1.0 → 1.1) because:
- Machine hash is based on hardware, not EXE hash
- License is tied to Product + Machine + validity period
- No EXE hash binding

## Uninstall/Reinstall

| Scenario | Behavior | Solution |
|----------|----------|----------|
| Reinstall same machine | License works after reinstall | Re-import license.dat if deleted |
| Uninstall | License file persists in AppData | Delete license.dat to deactivate |
| Windows reset | License lost | Contact ViyanInfo for reissue |
| Hardware change | License rejected | Contact ViyanInfo for reissue |
| Motherboard replacement | License rejected | Contact ViyanInfo for reissue |
| Disk replacement | License rejected | Contact ViyanInfo for reissue |

## License Renewal

1. Current license expires
2. User sees expiry message
3. User contacts ViyanInfo
4. ViyanInfo generates new signed license for same machine
5. User imports new `license.dat` via activation screen
6. Application works again - NO reinstall needed
7. Drift/SQLite database remains untouched
