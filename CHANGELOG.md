# Changelog
All notable changes to this project will be documented in this file.


## [0.3.0] - 2026-09-06
### Fixed
- Fix `Array.wrap` monkeypatch ([#21](https://github.com/tavrelkate/json-logic-rb/issues/21)).
  Before, requiring this gem defined `Array.wrap` globally on the core `Array` class. 
  Had conflict with ActiveSupport's with different `nil` handling (`[]` vs `[nil]`). Whichever loaded last silently won.

```ruby
require 'json_logic'

Array.respond_to?(:wrap)
# <= 0.2.0 => true
```

  Now the gem no longer touches `Array` globally. JsonLogic still wrap a single raw value into a array without dropping any elements (specially `nil`), but that rule now lives inside internal `JsonLogic::Semantics` instead of on core `Array`.

```ruby
require 'json_logic'

Array.respond_to?(:wrap)
# 0.3.0 => false
```

  ActiveSupport's own `Array.wrap` is no longer shadowed:

```ruby
require "active_support/core_ext/array/wrap"
require 'json_logic'

Array.wrap(nil)
# 0.3.0 => [] (ActiveSupport's behavior)
```

## [0.2.0] - 2026-02-17
### Added
- Add community-extra operators: `try`, `throw`, `exists`, `val`, and `??` (`coalesce`).
- Add structured error classes to distinguish invalid arguments, logic errors, and NaN cases.

### Changed
- Align behavior with community-extra compliance while keeping core JsonLogic compatibility.
- Standardize compliance runner usage with version flags.

```bash
ruby script/compliance.rb -v 1
ruby script/compliance.rb -v 2
```

Expected:

```text
compliance_v1: 272/272 passed (100.00%)
compliance_v2: 1138/1138 passed (100.00%)
```

### Fixed
- Fix `var` lookup when the resolved value is explicitly `false` ([#19](https://github.com/tavrelkate/json-logic-rb/issues/19)).
  Before (`<= 0.1.5`), `false` could fall through and return `nil`.

```ruby
rule = { "var" => "some_value" }
data = { "some_value" => false }

JsonLogic.apply(rule, data)
# <= 0.1.5 => nil
```

  Now the resolved `false` value is preserved.

```ruby
rule = { "var" => "some_value" }
data = { "some_value" => false }

JsonLogic.apply(rule, data)
# 0.2.0 => false
```

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
