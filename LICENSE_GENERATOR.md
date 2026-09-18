# ViyanInfo License Generator - Internal Tool Design

## Overview

The ViyanInfo License Generator is a separate internal/admin tool used ONLY by ViyanInfo/Product Owner. It is NOT part of the client application.

## Purpose

Generate signed license files (`license.dat`) for the Viyan Weighbridge application.

## Key Principles

- Private signing key NEVER exists in the client application
- Private signing key NEVER shipped with any product
- Client application CANNOT generate licenses
- Licenses are signed with Ed25519 asymmetric cryptography

## Inputs

| Field | Description | Example |
|-------|-------------|---------|
| Product | Target ViyanInfo product | VIYAN-WEIGHBRIDGE |
| Customer Name | Customer organization | ABC Industries |
| Customer ID | Customer identifier | CUSTOMER-001 |
| Machine ID | Machine hash from client | SHA256 hash |
| License Duration | 6 Months or 12 Months | 12_MONTH |

## Process

1. Enter customer information
2. Enter product ID
3. Enter machine ID (from client activation screen)
4. Select license duration (6 or 12 months)
5. Click "Generate License"
6. Tool outputs signed `license.dat` file

## License Format

```json
{
  "licenseId": "VY-WB-000001",
  "productId": "VIYAN-WEIGHBRIDGE",
  "customerId": "CUSTOMER-001",
  "customerName": "ABC Industries",
  "machineHash": "SHA256_MACHINE_HASH",
  "issuedAt": "2026-09-18T00:00:00Z",
  "expiresAt": "2027-09-18T00:00:00Z",
  "licenseType": "12_MONTH",
  "licenseVersion": 1,
  "signature": "HEX_ED25519_SIGNATURE"
}
```

## Date Calculation

Issued: 18-Sep-2026
6 month expiry: 18-Mar-2027
12 month expiry: 18-Sep-2027

Calendar-based calculation (not day count).

## Signing Process

1. Canonicalize license payload (sorted keys, no signature field)
2. Sign with Ed25519 private key
3. Append hex-encoded signature to license JSON
4. Output as `license.dat`

## Key Management

### Development
- Development signing key (separate from production)
- Safe for development/testing

### Production
- Production ViyanInfo signing key
- Stored securely (hardware security module preferred)
- Backed up securely offline
- NEVER committed to Git
- NEVER sent to customers

## .gitignore Entries

```
private_key.pem
private.key
secret.json
license.dat
license_state.dat
```

## Implementation Notes

The generator can be implemented as:
- A standalone Dart/Flutter desktop application
- A command-line Dart tool
- A web application hosted on ViyanInfo internal network

Must NEVER be packaged with the client EXE.
Must NEVER have access to the client source code repository.

## License Types

| Duration | Code |
|----------|------|
| 6 Months | 6_MONTH |
| 12 Months | 12_MONTH |
