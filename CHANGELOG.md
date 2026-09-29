# Changelog
All changes are documented in this file.


## [0.4.0] - 2026-09-29
### Changed
- Using an unsupported operation in a rule now raises `JsonLogic::UnrecognizedOperationError`.

  Before:

  ```ruby
  JsonLogic.apply({"unknown_operation" => [1, 2]})
  # 0.3.1 => {"unknown_operation" => [1, 2]}
  ```

  Now:

  ```ruby
  JsonLogic.apply({"unknown_operation" => [1, 2]})
  # 0.4.0 => raises JsonLogic::UnrecognizedOperationError: Unrecognized Operation
  ```
  
    Also applies however deeply the operation is nested inside the rule:
  
  ```ruby
  JsonLogic.apply({"if" => [true, {"+" => [1, {"unknown_operation" => 2}]}, 0]})
  # 0.4.0 => raises JsonLogic::UnrecognizedOperationError: Unrecognized Operation
  ```

## [0.3.1] - 2026-09-10
### Fixed
- Fix release `0.3.0` with an untracked file committed to the repository ([#24](https://github.com/tavrelkate/json-logic-rb/issues/24)).

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
⚠️ **Known issue**: this version has issue [#21](https://github.com/tavrelkate/json-logic-rb/issues/21). Fixed in `0.3.0`, upgrade recommended.

### Added
- Add community-extra operations: `try`, `throw`, `exists`, `val`, and `??` (`coalesce`).
- Add error classes to distinguish invalid arguments, logic errors and NaN cases.

### Changed
- Align behavior with community-extra compliance keeping core JsonLogic compatibility.
- Standardize compliance usage with version flags.

  ```bash
  ruby script/compliance.rb -v 1
  ruby script/compliance.rb -v 2
  ```

### Fixed
- Fix `var` lookup when the value is `false` ([#19](https://github.com/tavrelkate/json-logic-rb/issues/19)).

  ```ruby
  rule = { "var" => "some_value" }
  data = { "some_value" => false }
  
  JsonLogic.apply(rule, data)
  # <= 0.1.5 => nil
  ```

  Now the `false` value is preserved.

  ```ruby
  rule = { "var" => "some_value" }
  data = { "some_value" => false }
  
  JsonLogic.apply(rule, data)
  # 0.2.0 => false
  ```

## [0.1.5] - 2025-12-08
### Fixed
- Update operations to support `each_cons` inside comparisons.

## [0.1.4] - 2025-11-03
### Fixed
- Align JsonLogic semantics with the official specification across core Ruby types; correct `false` vs `null` equality.

## [0.1.3] - 2025-10-31
### Changed
- Update Json Logic semantic to follow official specification (for all core Ruby data structures).

## [0.1.2] - 2025-10-31
### Changed
- Update Json Logic to have `add_operation` method.

## [0.1.1] - 2025-10-31
### Changed
- Update Json Logic semantic to follow official specification.

## [0.1.0] - 2025-10-06
- First public release of `json-logic-rb`.
