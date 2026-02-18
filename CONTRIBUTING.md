# Contribution Guide

**Contributions of every size are very welcome!** Whether it's a small typo fix, a new operator, a better example, or a larger refactor — your help makes this gem better. If you're unsure where to start, open an issue and we can figure it out together.

We keep this gem small and sharp. If you can make it simpler – do it. If you can make it clearer – do it.

## Quick links

See **[README](./README.md)** — everything you need to understand the JsonLogic rule tree specifics in Ruby.
- See **[Development: compliance suites](#development-compliance-suites)** for suite download/rebuild commands.
## How to contribute

Fork. Branch. Change. Test. PR.


### Adding an operator

Read **[§ Adding Operations](./README.md#adding-operations)**. Prefer the class‑based API. The Proc & Lambda DSL is fine for a quick spike; promote to a class before merge.

Auto‑registration works for classes under [lib/json_logic/operations/](./lib/json_logic/operations/).


## Coding style

- **Follow [§ Security](./README.md#security)**.
- **Follow [§ JsonLogic Semantic](./README.md#jsonlogic-semantic)**.
- Prefer small, composable code with real examples.

## PR checklist

- [ ] Tests or examples included (when applicable).
- [ ] Compliance suite passes (see **[§ Compliance](./README.md#compliance)**).
- [ ] **[README](./README.md)** updated if user‑facing behavior changed.
- [ ] Version bumped in [Gem Version File](./lib/json_logic/version.rb).
- [ ] **[CHANGELOG](./CHANGELOG.md)** updated.

## Versioning

We use **[Semantic Versioning](https://semver.org/)**.

## Development: compliance suites

Use these commands when you need to download or rebuild suite files locally.

### Download core suite (v1)

```bash
mkdir -p spec/tmp/v1
curl -L https://jsonlogic.com/tests.json -o spec/tmp/v1/tests.json
```

### Build community suite (v2)

```bash
mkdir -p spec/tmp/v2
git clone https://github.com/json-logic/compat-tables.git /tmp/compat-tables
ruby script/build_tests_json.rb /tmp/compat-tables/suites spec/tmp/v2/tests.json
```

### Run compliance

```bash
ruby script/compliance.rb -v 1
ruby script/compliance.rb -v 2
```

Or run a specific suite file:

```bash
ruby script/compliance.rb -f spec/tmp/v2/tests.json
```
