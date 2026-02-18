# Changelog
All notable changes to this project will be documented in this file.


## [0.2.0] - 2026-02-17
- [feature] Add community-extra operators: `try`, `throw`, `exists`, `val`, `??` (`coalesce`).
- [feature] Align behavior with community-extra compliance in addition to core JsonLogic coverage.
- [feature] Introduce structured error classes for invalid arguments, logic errors, and NaN cases.
- [fix] Preserve explicit `false` in `var` lookup. `var` no longer falls through to default and returns `nil` for falsey values (`<= 0.1.5`) ([#19](https://github.com/tavrelkate/json-logic-rb/issues/19)).

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
