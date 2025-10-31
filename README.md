
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

```bash
gem install json-logic-rb
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

There are **two types of operations** in this implementation: Default Operations and Lazy Operations.

### 1. Default Operations

For **Default Operations**, the engine **evaluates all arguments first** and then calls the operator with the **resulting Ruby values**.  
This matches the reference behavior for arithmetic, comparisons, string operations, and other pure operations that do not control evaluation order.

**Groups and references:**

- [Numeric operations](https://jsonlogic.com/operations.html#numeric-operations)
- [String operations](https://jsonlogic.com/operations.html#string-operations)
- [Array operations](https://jsonlogic.com/operations.html#array-operations) — simple transforms like `merge`, membership `in`.

### 2. Lazy Operations

Some operations must control **whether** and **when** their arguments are evaluated. They implement branching, short-circuiting, or “apply a rule per item” semantics. For these **Lazy Operations**, the engine passes **raw sub-rules** and current data. The operator then evaluates only the sub-rules it actually needs.

**Groups and references:**

- **Branching / boolean control** — `if`, `?:`, `and`, `or`, `var`  
  [Logic & boolean operations](https://jsonlogic.com/operations.html#logic-and-boolean-operations) • [Truthiness](https://jsonlogic.com/truthy.html)

- **Enumerable operators** — `map`, `filter`, `reduce`, `all`, `none`, `some`  
  [Array operations](https://jsonlogic.com/operations.html#array-operations)

**How enumerable per-item evaluation works:**

1. The first argument is a rule that returns the list of items — evaluated **once** to a Ruby array.  
2. The second argument is the per-item rule — evaluated **for each item** with that item as the **current root**.  
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

Lazy operations **prevent evaluation** of branches you do not need. If division by zero raised an error (hypothetically), lazy control would avoid it:

```ruby
# "or" short-circuits: 1 is truthy, so the right side is NOT evaluated.
# If the right side were evaluated eagerly, it would attempt 1/0 (error).
JsonLogic.apply({ "or" => [1, { "/" => [1, 0] }] })
# => 1
```

> In this gem `/` returns `nil` on divide‑by‑zero, but these examples show **why** lazy evaluation is required by the spec: branching and boolean operators must **not** evaluate unused branches.

## Supported Operations (Built‑in)


Below is a list that mirrors the sections on [jsonlogic.com/operations.html](https://jsonlogic.com/operations.html) and shows what this gem (library) implements. From the reference page’s list, everything except `log` is implemented.

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

Need a custom operation? It’s straightforward.

### 1) Pick the operation type
Choose one of:
- **Default**
```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::Operation; end
```
- **Lazy**
```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::LazyOperation; end
```

See [§How](#how) for details.

### 2) Enable JsonLogic Semantics (optional)
Enable semantics to mirror JsonLogic’s comparison/truthiness in Ruby:

```ruby
using JsonLogic::Semantics
```


See [§JsonLogic Semantic](#jsonlogic-semantic) for details.

### 3) Create an Operation and provide a machine name

Operation methods use a consistent call shape.
  
- The first parameter is the **array of operator arguments**.
- The second is the current **data**.

  

Thanks to Ruby’s destructuring, you can unpack the argument array right in the method signature.

```ruby
class JsonLogic::Operations::StartsWith < JsonLogic::Operation
  def self.op_name = "starts_with"
  def call((str, prefix), _data)
    # str, prefix are ALREADY evaluated to Ruby values
    str.to_s.start_with?(prefix.to_s)
  end
end
```

### 4) Register the new operation

```ruby
JsonLogic::Engine.default.registry.register(JsonLogic::Operations::StartsWith)
```

After registration, use it in rules:

```json
{ "starts_with": [ { "var": "email" }, "admin@" ] }
```

### Alternative — register a Proc/Lambda

The public API is class‑oriented, but **technically** you can express an Operations as a `Proc`/`Lambda` and register it through a little anonymous functions.

DSL to register callables:

```ruby
module JsonLogic
  module DSL
    def self.register_proc(name, lazy: false, &block)
      base = lazy ? JsonLogic::LazyOperation : JsonLogic::Operation
      klass = Class.new(base) do
        define_singleton_method(:op_name) { name.to_s }
        define_method(:call) { |args, data| block.call(args, data) }
      end
      JsonLogic::Engine.default.registry.register(klass)
      klass
    end
  end
end
```

  

Is useful for rapid prototyping with minimal boilerplate;

  

```ruby
JsonLogic::DSL.register_proc("starts_with") do |(str, prefix), _data|
  str.to_s.start_with?(prefix.to_s)
end
```

Later you can “promote” the it into a full class.

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

1 >= "1.0" # => true
```

### Truthiness

JsonLogic’s truthiness differs from Ruby’s (see <https://jsonlogic.com/truthy.html>).  
In Ruby, only `false` and `nil` are falsey. In JsonLogic empty strings and empty arrays are also falsey.

**In Ruby:**
```ruby
!![]
# => true
```

While JsonLogic as was mentioned before has it's own truthiness:

**In Ruby (with JsonLogic Semantic):**

```ruby
include JsonLogic::Semantics

truthy?([])
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

- Rules are **data**, not code; no Ruby eval.
- Operations are **pure** (no IO, no network, no shell).
- Rules have **no write** access to anything.

## License

MIT — see [LICENSE](LICENSE).

## Authors

- [Valeriya Petrova](https://github.com/piatrova-valeriya1999)
- [Tavrel Kate](https://github.com/tavrelkate)
