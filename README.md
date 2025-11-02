



# json-logic-rb

Ruby implementation of [JsonLogic](https://jsonlogic.com/) — simple and extensible. Ships with a compliance runner for the official test suite.

<a  href="#"><img  alt="build"  src="https://img.shields.io/github/actions/workflow/status/your-org/json-logic-rb/ci-complience?branch=main">  <a  href="https://rubygems.org/gems/json-logic-rb"><img  alt="rubygems"  src="https://img.shields.io/gem/v/json-logic-rb"></a>  <a  href="LICENSE"><img  alt="license"  src="https://img.shields.io/badge/license-MIT-informational"></a>

## Table of Contents
- [What](#what)
- [Install](#install)
- [Quick start](#quick-start)
- [How](#how)
  - [1. Default Operations](#1-default-operations)
  - [2. Lazy Operations](#2-lazy-operations)
- [Supported Operations (Built‑in)](#supported-operations-built-in)
- [Adding Operations](#adding-operations)
- [JsonLogic Semantic](#jsonlogic-semantic)
- [Compliance and tests](#compliance-and-tests)
- [Security](#security)
- [License](#license)
- [Authors](#authors)

---

## What
JsonLogic rules are JSON trees. The engine walks that tree and returns a Ruby value.

## Install

Download the gem locally
```bash
gem install json-logic-rb
```
If needed – add to your  Gemfile

```ruby
gem "json-logic-rb"
```

Then install
```shell
bundle install
```

## Quick start

```ruby
require 'json_logic'

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

There are two types of operations: [Default Operations](#1-default-operations)  and [Lazy Operations](#2-lazy-operations)

### 1. Default Operations

For **Default Operations**, the it evaluates all arguments first and then calls the operator with the resulting Ruby values.
This matches the reference behavior for arithmetic, comparisons, string operations, and other pure operations that do not control evaluation order.

**Groups and references:**

- [Numeric operations](https://jsonlogic.com/operations.html#numeric-operations)
- [String operations](https://jsonlogic.com/operations.html#string-operations)
- [Array operations](https://jsonlogic.com/operations.html#array-operations) — simple transforms like `merge`, membership `in`.

### 2. Lazy Operations

Some operations must control whether and when their arguments are evaluated. They implement branching, short-circuiting, or “apply a rule per item” semantics. For these **Lazy Operations**, the engine passes raw sub-rules and data. The operator then evaluates only the sub-rules it actually needs.

**Groups and references:**

- **Branching / boolean control** — `if`, `?:`, `and`, `or`, `var`
  [Logic & boolean operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations)

- **Enumerable operators** — `map`, `filter`, `reduce`, `all`, `none`, `some`
  [Array operations](https://jsonlogic.com/operations.html#array-operations)

**How enumerable per-item evaluation works:**

1. The first argument is a rule that returns the list of items — evaluated once to a Ruby array.
2. The second argument is the per-item rule — evaluated for each item with that item as the current root.
3. For `reduce`, the current item is also available as `"current"`, and the running total as `"accumulator"`.


**Example #1**

```ruby
# filter: keep numbers >= 2
JsonLogic.apply(
  { "filter" => [ { "var" => "ints" }, { ">=" => [ { "var" => "" }, 2 ] } ] },
  { "ints" => [1,2,3] }
)
# => [2, 3]
```

**Example #2**

```ruby
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

Lazy operations  prevent evaluation of branches you do not need.

If hypothetically division by zero raises an error, lazy control would avoid it.
```ruby
JsonLogic.apply({ "or" => [1, { "/" => [1, 0] }] })
# => 1
```

> In this gem division returns nil on divide‑by‑zero, but this example show why lazy evaluation is required by the spec: branching and boolean operators must not evaluate unused branches.

## Supported Operations (Built‑in)


Below is a list that mirrors the sections on [Json Logic Website Opeations](https://jsonlogic.com/operations.html) and shows what this gem implements.

| Operator | Supported |
|---|---:|
|  `var`  | ✅ |
|  `missing`  | ✅ |
|  `missing_some`  | ✅ |
|[Logic and Boolean Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations])
|  `if`  | ✅ |
|  `==`  | ✅ |
|  `===`  | ✅ |
|  `!=`  | ✅ |
|  `!==`  | ✅ |
|  `!`  | ✅ |
|  `!!`  | ✅ |
|  `or`  | ✅ |
|  `and`  | ✅ |
|  `?:`  | ✅ |
|[Numeric Operations](https://jsonlogic.com/operations.html#numeric-operations)|
|  `map`  | ✅ |
|  `reduce`  | ✅ |
|  `filter`  | ✅ |
|  `all`  | ✅ |
|  `none`  | ✅ |
|  `some`  | ✅ |
|  `merge`  | ✅ |
|  `in`  | ✅ |
|[Array Operations](https://jsonlogic.com/operations.html#array-operations)|
|  `map`  | ✅ |
|  `reduce`  | ✅ |
|  `filter`  | ✅ |
|  `all`  | ✅ |
|  `none`  | ✅ |
|  `some`  | ✅ |
|  `merge`  | ✅ |
|  `in`  | ✅ |
|[String Operations](https://jsonlogic.com/operations.html#string-operations)|
|  `in`  | ✅ |
|  `cat`  | ✅ |
|  `substr`  | ✅ |
|Miscellaneous|
|  `log` | 🚫 |

## Adding Operations

Need a custom Operation? It’s straightforward. Start small with a Proc or Lambda. If needed – promote it to a Class.



### 	Enable JsonLogic Semantics (optional)
Enable semantics to mirror JsonLogic’s comparison and truthiness in Ruby.

See [§JsonLogic Semantic](#jsonlogic-semantic) for details.


### Parameters

Operator function use a consistent call shape:

-   First parameter: **array of operator arguments** (you can destructure it).

-   Second parameter: current **data**.
```ruby
->((string, prefix), data) { string.to_s.start_with?(prefix.to_s) }
```

### Proc / Lambda

Pick the Operation type.

[Default Operation](#1-default-operations) mode passes values.

```ruby
JsonLogic.add_operation("starts_with") do |(string_value, prefix_value), _data|
  string_value.to_s.start_with?(prefix_value.to_s)
end
```
[Lazy Operation](#2-lazy-operations) mode passes raw rules (you evaluate them):

```ruby
JsonLogic.add_operation("starts_with", lazy: true) do |(string_rule, prefix_rule), data|
  string_value = JsonLogic.apply(string_rule, data)
  prefix_value = JsonLogic.apply(prefix_rule, data)
  string_value.to_s.start_with?(prefix_value.to_s)
end
```

See [§How](https://github.com/tavrelkate/json-logic-rb?tab=readme-ov-file#how) for details.

Use immediately:

```ruby
JsonLogic.apply({ "starts_with" => [ { "var" => "email" }, "admin@" ] })
```


### Class

Pick the Operation type. It has the same call shape.

[Default Operation](#1-default-operations)  – Inherit `JsonLogic::Operation`.

```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::Operation
  def self.name = "starts_with"
  def call(string_value, prefix_value), _data) = string_value.to_s.start_with?(prefix_value.to_s)
end
```

[Lazy Operation](#2-lazy-operations)  – Inherit `JsonLogic::LazyOperation`.

Register explicitly:

```ruby
JsonLogic::Engine.default.registry.register(JsonLogic::Operations::StartsWith)
```

Now, Class is ready to use.

```ruby
JsonLogic.apply({ "starts_with" => [ { "var" => "email" }, "admin@" ] })
```








## JsonLogic Semantic

All supported Operations follow JsonLogic semantics.

### Comparisons
As JsonLogic primary developed in JavaScript it inherits JavaScript's type coercion in build-in Operations. JsonLogic (JS‑style) comparisons coerce types; Ruby does not.

**JavaScript:**

```js
1 >= "1.0" // true
```

**Ruby:**

```ruby
1 >= "1.0"
# ArgumentError: comparison of Integer with String failed
```

**Ruby (with JsonLogic semantics enabled):**

```ruby
using JsonLogic::Semantics

1 >= "1.0"
# => true
```

### Truthiness

JsonLogic’s truthiness differs from Ruby’s (see  [Json Logic Website Truthy and Falsy](https://jsonlogic.com/truthy.html)).
In Ruby, only `false` and `nil` are falsey. In JsonLogic empty strings and empty arrays are falsey too.

**In Ruby:**
```ruby
!![]
# => true
```

While JsonLogic as was mentioned before has it's own truthiness.

**In Ruby (with JsonLogic Semantic):**

```ruby
using JsonLogic::Semantics

!![]
# => false
```


## Compliance and tests

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

## Security

- RULES ARE DATA; NO RUBY EVAL;
- OPERATIONS ARE PURE; NO IO, NO NETWORK; NO SHELL;
- RULES HAVE NO WRITE ACCESS TO ANYTHING;


## License

MIT — see [LICENSE](LICENSE).

## Authors

- [Valeriya Petrova](https://github.com/piatrova-valeriya1999)
- [Tavrel Kate](https://github.com/tavrelkate)
