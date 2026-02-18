











# json-logic-rb

Ruby implementation of [JsonLogic](https://jsonlogic.com/) — elegant and extensible. Full compliance with both core and community-extended specifications.

[![jsonlogic core][src-core]](https://jsonlogic.com/tests.json) [![jsonlogic community][src-community]](https://github.com/json-logic/compat-tables/tree/main/suites) [![compliance 100%](https://img.shields.io/badge/compliance-100%25-brightgreen)](https://github.com/tavrelkate/json-logic-rb/actions/workflows/compliance.yml?query=branch%3Amain) <a href="https://rubygems.org/gems/json-logic-rb"><img alt="rubygems" src="https://img.shields.io/gem/v/json-logic-rb"></a> <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-informational"></a>

## Table of Contents
- [What](#what)
- [Install](#install)
- [Quick start](#quick-start)
- [How](#how)
  - [1. Default Operations](#1-default-operations)
  - [2. Lazy Operations](#2-lazy-operations)
- [Why laziness matters?](#why-laziness-matters)
- [Compliance and tests](#compliance-and-tests)
  - [Script](#script)
- [Supported Operations (Built‑in)](#supported-operations-built-in)
- [Adding Operations](#adding-operations)
  - [Enable JsonLogic Semantics (optional)](#enable-jsonlogic-semantics-optional)
  - [Parameters](#parameters)
  - [Proc / Lambda](#proc--lambda)
  - [Class](#class)
- [JsonLogic Semantic](#jsonlogic-semantic)
  - [Comparisons](#comparisons)
  - [Truthiness](#truthiness)
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
require 'json_logic'

rule = { "var" => "user.age" }
data = { "user" => { "age" => 42 } }

JsonLogic.apply(rule, data)
# => 42
```

## How

There are two types of operations: [Default Operations](#1-default-operations)  and [Lazy Operations](#2-lazy-operations).

### 1. Default Operations

For **Default Operations**, the it evaluates all arguments first and then calls the operator with the resulting Ruby values.
This matches the reference behavior for arithmetic, comparisons, string operations, and other pure operations that do not control evaluation order.

**Groups and references:**

- [Numeric operations](https://jsonlogic.com/operations.html#numeric-operations)
- [String operations](https://jsonlogic.com/operations.html#string-operations)
- [Array operations](https://jsonlogic.com/operations.html#array-operations) — simple transform like `merge`.

### 2. Lazy Operations

Some operations must control whether and when their arguments are evaluated. They implement branching, short-circuiting, or “apply a rule per item” semantics. For these **Lazy Operations**, the engine passes raw sub-rules and data. The operator then evaluates only the sub-rules it actually needs.

**Groups and references:**

- [Logic and Boolean Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations) — short-circuit/branching like `or`.
- [Comparison operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations) — equality/ordering like `==`.
- [Array operations](https://jsonlogic.com/operations.html#array-operations) — enumerable evaluation like `map`.


**Example #1**

```ruby
# filter: keep numbers >= 2
JsonLogic.apply(
  { "filter" => [ { "var" => "ints" }, { ">=" => [ { "var" => "" }, 2 ] } ] },
  { "ints" => [1,2,3] }
)
# => [2, 3]
```

### Why laziness matters?

Lazy operations prevent evaluation of branches you do not need.

If hypothetically division by zero raises an error, lazy control would avoid it.
```ruby
JsonLogic.apply({ "or" => [1, { "/" => [1, 0] }] })
# => 1
```

> In this gem division returns nil on divide‑by‑zero, but this example show why lazy evaluation is required by the spec: branching and boolean operators must not evaluate unused branches.






## Compliance and tests

The JsonLogic specification provides  test suites — concrete inputs with expected outputs that validate the implementation of operations. The specification come in two variants:
- [![jsonlogic core][src-core]](https://jsonlogic.com/tests.json)  — [original JsonLogic website](https://jsonlogic.com/tests.json);
- [![jsonlogic community][src-community]](https://github.com/json-logic/compat-tables/tree/main/suites) — [extensions built on top of the core](https://github.com/json-logic/compat-tables/tree/main/suites);

 The "extra"  exists because "core" hasn't changed in years — and that’s fine, "core"  is a solid, finished foundation. Think of it as v1, while "extra" is the v2+ evolution as there are no visible plans to change the original.

### Script

Download test suite v1:

```bash
mkdir -p spec/tmp/v1
curl -L https://jsonlogic.com/tests.json -o spec/tmp/v1/tests.json
```

Download test suite v2:

```bash
mkdir -p spec/tmp/v2
git clone https://github.com/json-logic/compat-tables.git /tmp/compat-tables
ruby script/build_tests_json.rb /tmp/compat-tables/suites spec/tmp/v2/tests.json
```

Run by version:

```bash
ruby script/compliance.rb -v 1
ruby script/compliance.rb -v 2
```

Run by file path:

```bash
ruby script/compliance.rb -f spec/tmp/v2/tests.json
```


## Supported Operations (Built‑in)

Don’t expect JsonLogic to include every specialized operation. It’s intentionally small and not a programming language. It will never do everything.

You can add custom operations yourself — check out  [§Adding Operations](https://www.google.com/search?q=%23adding-operations)— or consider if the logic can be expressed with what’s already there.

If a feature is simple, lightweight, and universally needed — open an issue or discussion.


| Operator | Supported | Source |
|---|---:|---|
| [Data / Presence](https://jsonlogic.com/operations.html#accessing-data) | | |
| `var` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `val` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| `missing` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `missing_some` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `exists` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| [Logic and Boolean Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations) | | |
| `if` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `?:` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `and` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `or` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `!` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `!!` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| [Comparison Operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations) | | |
| `==` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `===` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `!=` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `!==` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `>` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `>=` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `<` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `<=` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| [Numeric Operations](https://jsonlogic.com/operations.html#numeric-operations) | | |
| `+` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `-` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `*` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `/` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `%` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `min` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `max` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| [Array Operations](https://jsonlogic.com/operations.html#array-operations) | | |
| `map` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `reduce` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `filter` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `all` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `none` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `some` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `merge` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| [String Operations](https://jsonlogic.com/operations.html#string-operations) | | |
| `in` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `cat` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| `substr` | ✅ | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |
| [Community Extensions](https://github.com/json-logic/compat-tables/tree/main/suites) | | |
| `??` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| `try` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| `throw` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| `preserve` | ✅ | ![jsonlogic community](https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square) |
| Docs-only / Not implemented | | |
| `log` | 🚫 | ![jsonlogic](https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square) |


[src-core]: https://img.shields.io/badge/jsonlogic-core-2ea44f?style=flat-square
[src-community]: https://img.shields.io/badge/jsonlogic--community-extra-0366d6?style=flat-square

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

## Security

- RULES ARE DATA; NO RUBY EVAL;
- OPERATIONS ARE PURE; NO IO, NO NETWORK; NO SHELL;
- RULES HAVE NO WRITE ACCESS TO ANYTHING;


## License

MIT — see [LICENSE](LICENSE).

## Authors

- [Valeriya Petrova](https://github.com/piatrova-valeriya1999)
- [Tavrel Kate](https://github.com/tavrelkate)
