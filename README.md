# json-logic-rb

Ruby implementation of [JsonLogic](https://jsonlogic.com/) — simple and extensible.  Ships with a compliance runner for the official test suite.

  <a href="#"><img alt="build" src="https://img.shields.io/github/actions/workflow/status/your-org/json-logic-rb/ci.yml?branch=main"> <a href="https://rubygems.org/gems/json-logic-rb"><img alt="rubygems" src="https://img.shields.io/gem/v/json-logic-rb"></a> <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-informational"></a>



## What
JsonLogic rules are JSON trees. The engine walks that tree and returns a Ruby value.

## Install

```bash
gem install json-logic-rb
```

## Quick start

```ruby
require "json-logic-rb"

rule = { "+" => [1, 2, 3] }

JsonLogic.apply(rule)
# => 6.0
```

With data:

```ruby
JsonLogic.apply({ "var" => "user.age" }, { "user" => { "age" => 42 } })
# => 42
```


## How

There are **two kinds of operators** in this implementation. This mapping follows the official behavior described on jsonlogic.com.

### 1) Operators (default)

For **operators**, the engine **evaluates all arguments first** and then calls the operator with the **resulting Ruby values**.
This matches the reference behavior for arithmetic, comparisons, string operations, and other pure operators that do not control evaluation order.

**Official docs:**

-   Numeric Operations — [https://jsonlogic.com/operations.html#numeric-operations](https://jsonlogic.com/operations.html#numeric-operations)

-   String Operations — [https://jsonlogic.com/operations.html#string-operations](https://jsonlogic.com/operations.html#string-operations)

-   Array Operations (simple transforms like `merge`, membership `in`) — [https://jsonlogic.com/operations.html#array-operations](https://jsonlogic.com/operations.html#array-operations)




### 2) Lazy  operators

Some operators must control **whether** and **when** their arguments are evaluated.
They implement branching, short-circuiting, or “apply a rule per item” semantics.
For these **lazy  operators**, the engine passes **raw sub-rules** and current `data`.
The operator then evaluates only the sub-rules it actually needs.

**Groups and references:**

-   **Branching / boolean control** — `if`, `?:`, `and`, `or`, `var`
    Docs: Logic and Boolean Operations — [https://jsonlogic.com/operations.html#logic-and-boolean-operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations)
    Truthiness table used by these operators — [https://jsonlogic.com/truthy.html](https://jsonlogic.com/truthy.html)

-   **Enumerable operators** — `map`, `filter`, `reduce`, `all`, `none`, `some`
    Docs: Array Operations — [https://jsonlogic.com/operations.html#array-operations](https://jsonlogic.com/operations.html#array-operations)


**How per-item evaluation works:**

1.  The first argument is a rule that returns the list of items — evaluated **once** to a Ruby array.

2.  The second argument is the per-item rule — evaluated **for each item** with that item as the **current root**.

3.  For `reduce`, the current item is also available as `"current"`, and the running total as `"accumulator"` (this mirrors the reference usage in docs and tests).


**Examples**
```ruby
`# filter: keep numbers >= 2
JsonLogic.apply(
  { "filter" => [ { "var" => "ints" }, { ">=" => [ { "var" => "" }, 2 ] } ] },
  { "ints" => [1,2,3] }
)
# => [2, 3]

# reduce: sum using "current" and "accumulator"
JsonLogic.apply(
  { "reduce" => [
      { "var" => "ints" },
      { "+" => [ { "var" => "accumulator" }, { "var" => "current" } ] }, 0 ]
  },
  { "ints" => [1,2,3,4] }
)
# => 10.0
```

### Why laziness matters?

Lazy operators **prevent evaluation** of branches you do not need.
If division by zero raised an error (hypothetically), lazy control would avoid it:

```ruby
# "or" short-circuits: 1 is truthy, so the right side is NOT evaluated.
# If the right side were evaluated eagerly, it would attempt 1/0 (error).
JsonLogic.apply({ "or" => [1, { "/" => [1, 0] }] })
# => 1

# "if" evaluates only the 'then' branch when condition is true.
# The 'else' branch with 1/0 is never evaluated.
JsonLogic.apply({ "if" => [true, 42, { "/" => [1, 0] }] })
# => 42
```
>In this gem (library) `/` returns `nil` on divide-by-zero, but these examples show **why** lazy evaluation is required by the spec: branching and boolean operators must **not** evaluate unused branches.



---

##  Supported Built-in Operations

Below is a checklist that mirrors the sections on **jsonlogic.com/operations.html** and shows what this gem (library) implements.


### Accessing Data
| Operator | Supported | Notes |
|---|---:|---|
| `var` | ✅ |  |
| `missing` | ✅ | Returns array of missing keys; works with complex sources (e.g. `merge` result). |
| `missing_some` | ✅ | Returns `[]` when the minimum is met, otherwise missing keys. |


### [Logic and Boolean Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations])
| Operator | Supported | Notes |
|---|---:|---|
| `if` | ✅ |  |
| `==` | ✅ |  |
| `===` | ✅ | Strict equality (same type and value). |
| `!=` | ✅ |  |
| `!==` | ✅ | |
| `!` | ✅ | Follows JsonLogic truthiness. |
| `!!` | ✅ | Follows JsonLogic truthiness. |
| `or` | ✅ | Returns first truthy / last value; |
| `and` | ✅ | Returns first falsy / last value; |
| `?:` | ✅ | Returns the truth. |


### [Numeric Operations](https://jsonlogic.com/operations.html#numeric-operations)
| Operator / Topic | Supported | Notes |
|---|---:|---|
| `>` `>=` `<` `<=` | ✅ | |
| Between (pattern) | ✅ | Use `<`/`<=` with 3 args (not a separate op). |
| `max` / `min` | ✅ |  |
| `+` `-` `*` `/` | ✅ | Unary `-` negates; unary `+` casts to number; `/` returns `nil` on divide‑by‑zero. |
| `%` | ✅ |  |


### [Array Operations](https://jsonlogic.com/operations.html#array-operations)
| Operator | Supported | Notes |
|---|---:|---|
| `map` | ✅ | |
| `reduce` | ✅ | Per‑item rule sees `"current"` and `"accumulator"`. |
| `filter` | ✅ | Keeps items where per‑item rule is truthy (follows JsonLogic truthiness). |
| `all` | ✅ | `false` on empty; all per‑item are truthy (follows JsonLogic truthiness). |
| `none` | ✅ | `true` on empty; none per‑item are truthy (follows JsonLogic truthiness). |
| `some` | ✅ | `false` on empty; any per‑item is truthy (follows JsonLogic truthiness). |
| `merge` | ✅ | Flattens arguments into a single array; non‑arrays cast to singleton arrays. |
| `in` | ✅ | If second arg is an array: membership test. |


### [String Operations](https://jsonlogic.com/operations.html#string-operations)
| Operator | Supported | Notes |
|---|---:|---|
| `in` | ✅ | If second arg is a string: substring test. |
| `cat` | ✅ | Concatenate arguments as strings (no delimiter). |
| `substr` | ✅ | Start index can be negative; length can be omitted or negative (mirrors the official behavior). |


### Miscellaneous
| Operator | Supported | Notes |
|---|---:|---|
| `log` | 🚫 | Not implemented by default (and not part of the compliance tests). |

**Summary:** From the reference page’s list, everything except `log` is implemented.
(“Between” is not a standalone operator, but the `<`/`<=` 3‑argument form is supported.)

---

## Extending (add your own operator)

### Operation Type

Each operator is a class.
-  **Value operations** inherit `JsonLogic::Operation` (engine passes values).

- **Lazy operations** inherit `JsonLogic::LazyOperation` (engine passes raw sub‑rules).

- **Enumerable operations** inherit `JsonLogic::EnumerableOperation` (standardized data binding for per‑item rules).

### Guide

First, create the Class for you Operation based on it's type:
```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::Operation
  def self.op_name = "starts_with"  # {"starts_with": [string, prefix]}

  def call((str, prefix), _data)
    str.to_s.start_with?(prefix.to_s)
  end
end
```

Second, register your operation:
```ruby
JsonLogic::Engine.default.registry.register(JsonLogic::Operations::StartsWith)
```

Use it!
```ruby
rule = {
  "if" => [
    { "starts_with" => [ { "var" => "email" }, "admin@" ] },
    "is_admin",
    "regular_user"
  ]
}

p JsonLogic.apply(rule, { "email" => "admin@example.com" })
# => "is_admin"
p JsonLogic.apply(rule, { "email" => "user@example.com" })
# => "regular_user"
```

---

## API

```ruby
# Main facade
JsonLogic.apply(rule, data = nil)  # => value

# Engine/Registry (advanced)
engine = JsonLogic::Engine.default
engine.evaluate(rule, data)

# Register a custom op class (auto‑registration is also supported)
engine.registry.register(JsonLogic::Operations::StartsWith)
```

---

## Compliance  & tests
Optional: quick self-test

```bash
ruby test/selftest.rb
```

Official test suite
1. Fetch the official suite

```bash
mkdir -p spec/tmp
curl -fsSL https://jsonlogic.com/tests.json -o spec/tmp/tests.json
```
2. Run it
```bash
ruby script/compliance.rb spec/tmp/tests.json
```

Expected output
```bash
# => Compliance: X/X passed
```

---

## Security

- Rules are **data**, not code; no Ruby eval.
- When evaluating untrusted rules, consider adding a timeout  and error handling at the call site.
- Custom operations should be **pure** (no IO, no network, no shell).

---
Ruby implementation of [JsonLogic](https://jsonlogic.com/) — simple and extensible.
Ships with a compliance runner for the official test suite.

  <a href="#"><img alt="build" src="https://img.shields.io/github/actions/workflow/status/your-org/json-logic-rb/ci.yml?branch=main"> <a href="https://rubygems.org/gems/json-logic-rb"><img alt="rubygems" src="https://img.shields.io/gem/v/json-logic-rb"></a> <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-informational"></a>



## What
JsonLogic rules are JSON trees. The engine walks that tree and returns a Ruby value.

## Install

```bash
gem install json-logic-rb
```

## Quick start

```ruby
require "json-logic-rb"

rule = { "+" => [1, 2, 3] }

JsonLogic.apply(rule)
# => 6.0
```

With data:

```ruby
JsonLogic.apply({ "var" => "user.age" }, { "user" => { "age" => 42 } })
# => 42
```


There are **two kinds of operators** in this implementation. This mapping follows the official behavior described on jsonlogic.com.

### 1) Operators (default)

For **operators**, the engine **evaluates all arguments first** and then calls the operator with the **resulting Ruby values**.
This matches the reference behavior for arithmetic, comparisons, string operations, and other pure operators that do not control evaluation order.

**Official docs:**

-   Numeric Operations — [https://jsonlogic.com/operations.html#numeric-operations](https://jsonlogic.com/operations.html#numeric-operations)

-   String Operations — [https://jsonlogic.com/operations.html#string-operations](https://jsonlogic.com/operations.html#string-operations)

-   Array Operations (simple transforms like `merge`, membership `in`) — [https://jsonlogic.com/operations.html#array-operations](https://jsonlogic.com/operations.html#array-operations)




### 2) Lazy  operators

Some operators must control **whether** and **when** their arguments are evaluated.
They implement branching, short-circuiting, or “apply a rule per item” semantics.
For these **lazy  operators**, the engine passes **raw sub-rules** and current `data`.
The operator then evaluates only the sub-rules it actually needs.

**Groups and references:**

    Truthiness table used by these operators — [https://jsonlogic.com/truthy.html](https://jsonlogic.com/truthy.html)

-   **Enumerable operators** — `map`, `filter`, `reduce`, `all`, `none`, `some`
    Docs: Array Operations — [https://jsonlogic.com/operations.html#array-operations](https://jsonlogic.com/operations.html#array-operations)


**How per-item evaluation works:**

1.  The first argument is a rule that returns the list of items — evaluated **once** to a Ruby array.

2.  The second argument is the per-item rule — evaluated **for each item** with that item as the **current root**.

3.  For `reduce`, the current item is also available as `"current"`, and the running total as `"accumulator"` (this mirrors the reference usage in docs and tests).


**Examples**
```ruby
`# filter: keep numbers >= 2
JsonLogic.apply(
  { "filter" => [ { "var" => "ints" }, { ">=" => [ { "var" => "" }, 2 ] } ] },
  { "ints" => [1,2,3] }
)
# => [2, 3]

# reduce: sum using "current" and "accumulator"
JsonLogic.apply(
  { "reduce" => [
      { "var" => "ints" },
      { "+" => [ { "var" => "accumulator" }, { "var" => "current" } ] }, 0 ]
  },
  { "ints" => [1,2,3,4] }
)
# => 10.0
```

### Why laziness matters?

Lazy operators **prevent evaluation** of branches you do not need.
If division by zero raised an error (hypothetically), lazy control would avoid it:

```ruby
# "or" short-circuits: 1 is truthy, so the right side is NOT evaluated.
# If the right side were evaluated eagerly, it would attempt 1/0 (error).
JsonLogic.apply({ "or" => [1, { "/" => [1, 0] }] })
# => 1

# "if" evaluates only the 'then' branch when condition is true.
# The 'else' branch with 1/0 is never evaluated.
JsonLogic.apply({ "if" => [true, 42, { "/" => [1, 0] }] })
# => 42
```
>In this gem (library) `/` returns `nil` on divide-by-zero, but these examples show **why** lazy evaluation is required by the spec: branching and boolean operators must **not** evaluate unused branches.



---

##  Supported Built-in Operations

Below is a checklist that mirrors the sections on **jsonlogic.com/operations.html** and shows what this gem (library) implements.


### Accessing Data
| Operator | Supported | Notes |
|---|---:|---|
| `var` | ✅ |  |
| `missing` | ✅ | Returns array of missing keys; works with complex sources (e.g. `merge` result). |
| `missing_some` | ✅ | Returns `[]` when the minimum is met, otherwise missing keys. |
### [Logic and Boolean Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations])
| Operator | Supported | Notes |
|---|---:|---|
| `if` | ✅ |  |
| `==` | ✅ |  |
| `===` | ✅ | Strict equality (same type and value). |
| `!=` | ✅ |  |
| `!==` | ✅ | |
| `!` | ✅ | Follows JsonLogic truthiness. |
| `!!` | ✅ | Follows JsonLogic truthiness. |
| `or` | ✅ | Returns first truthy / last value; |
| `and` | ✅ | Returns first falsy / last value; |
| `?:` | ✅ | Returns the truth. |
### [Numeric Operations](https://jsonlogic.com/operations.html#numeric-operations)
| Operator / Topic | Supported | Notes |
|---|---:|---|
| `>` `>=` `<` `<=` | ✅ | |
| Between (pattern) | ✅ | Use `<`/`<=` with 3 args (not a separate op). |
| `max` / `min` | ✅ |  |
| `+` `-` `*` `/` | ✅ | Unary `-` negates; unary `+` casts to number; `/` returns `nil` on divide‑by‑zero. |
| `%` | ✅ |  |
### [Array Operations](https://jsonlogic.com/operations.html#array-operations)
| Operator | Supported | Notes |
|---|---:|---|
| `map` | ✅ | |
| `reduce` | ✅ | Per‑item rule sees `"current"` and `"accumulator"`. |
| `filter` | ✅ | Keeps items where per‑item rule is truthy (follows JsonLogic truthiness). |
| `all` | ✅ | `false` on empty; all per‑item are truthy (follows JsonLogic truthiness). |
| `none` | ✅ | `true` on empty; none per‑item are truthy (follows JsonLogic truthiness). |
| `some` | ✅ | `false` on empty; any per‑item is truthy (follows JsonLogic truthiness). |
| `merge` | ✅ | Flattens arguments into a single array; non‑arrays cast to singleton arrays. |
| `in` | ✅ | If second arg is an array: membership test. |
### [String Operations](https://jsonlogic.com/operations.html#string-operations)
| Operator | Supported | Notes |
|---|---:|---|
| `in` | ✅ | If second arg is a string: substring test. |
| `cat` | ✅ | Concatenate arguments as strings (no delimiter). |
| `substr` | ✅ | Start index can be negative; length can be omitted or negative (mirrors the official behavior). |


### Miscellaneous
| Operator | Supported | Notes |
|---|---:|---|
| `log` | 🚫 | Not implemented by default (and not part of the compliance tests). |

**Summary:** From the reference page’s list, everything except `log` is implemented.
(“Between” is not a standalone operator, but the `<`/`<=` 3‑argument form is supported.)

---

## Extending (add your own operator)

Each operator is a class.
-  **Value operations** inherit `JsonLogic::Operation` (engine passes values).
- **Lazy operations** inherit `JsonLogic::LazyOperation` (engine passes raw sub‑rules).
- **Enumerable operations** inherit `JsonLogic::EnumerableOperation` (standardized data binding for per‑item rules).

First, create the Class for you Operation based on it's type:
```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::Operation
  def self.op_name = "starts_with"  # {"starts_with": [string, prefix]}

  def call((str, prefix), _data)
    str.to_s.start_with?(prefix.to_s)
  end
end
```

Secondly, register your operation:
```ruby
JsonLogic::Engine.default.registry.register(JsonLogic::Operations::StartsWith)
```

Use it!
```ruby
rule = {
  "if" => [
    { "starts_with" => [ { "var" => "email" }, "admin@" ] },
    "is_admin",
    "regular_user"
  ]
}

p JsonLogic.apply(rule, { "email" => "admin@example.com" })
# => "is_admin"
p JsonLogic.apply(rule, { "email" => "user@example.com" })
# => "regular_user"
```

---

## API

```ruby
# Main facade
JsonLogic.apply(rule, data = nil)  # => value

# Engine/Registry (advanced)
engine = JsonLogic::Engine.default
engine.evaluate(rule, data)

# Register a custom op class (auto‑registration is also supported)
engine.registry.register(JsonLogic::Operations::StartsWith)
```

---

## Compliance  & tests
Optional: quick self-test

```bash
ruby test/selftest.rb
```

Official test suite
1. Fetch the official suite

```bash
mkdir -p spec/tmp
curl -fsSL https://jsonlogic.com/tests.json -o spec/tmp/tests.json
```
2. Run it
```bash
ruby script/compliance.rb spec/tmp/tests.json
```

Expected output
```bash
# => Compliance: X/X passed
```

---

## Security

- Rules are **data**, not code; no Ruby eval.
- When evaluating untrusted rules, consider adding a timeout  and error handling at the call site.
- Custom operations should be **pure** (no IO, no network, no shell).

---
