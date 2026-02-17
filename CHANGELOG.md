# Changelog
All notable changes to this project will be documented in this file.


## [0.2.0] - 2026-02-17
- Alignment with the v2 community-extra compliance, extending behavior beyond the original core specification. This update adds support for the following operations:
  - try
  - throw
  - exists
  - val
  - ?? (coalesce)
- Introduced structured error classes to distinguish between invalid arguments, logical errors, and NaN-related cases, providing more concrete and consistent error reporting.

## [0.1.5] - 2025-12-08
- [fix] Update Operations to support "each_cons" inside comparisons.

## [0.1.4] - 2025-11-03
- [fix] Align JsonLogic semantics with the official spec across core Ruby types; correct false vs null equality.

## [0.1.3] - 2025-10-31
- Update Json Logic semantic to follow official specification (for all core Ruby Data structures).

## [0.1.2] - 2025-10-31
- Update Json Logic to have #add_operation method.

## [0.1.1] - 2025-10-31
- Update Json Logic semantic to follow official specification.

## [0.1.0] - 2025-10-06
- First public release of `json-logic-rb`.
