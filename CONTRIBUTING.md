

# Contribution Guide

**Contributions of every size are very welcome!** Whether it's a small typo fix, a new operator, a better example, or a larger refactor — your help makes this gem better. If you're unsure where to start, open an issue and we can figure it out together.

We keep this gem small and sharp. If you can make it simpler – do it. If you can make it clearer – do it.

## Quick links

See **[README](./README.md)** — everything you need to understand the JsonLogic rule tree.
## How to contribute

Fork. Branch. Change. Test. PR.


### Adding an operator

Read **[§ Adding Operations](./README.md#adding-operations)**. Prefer the class‑based API. The Proc/Lambda DSL is fine for a quick spike; promote to a class before merge.

Auto‑registration works for classes under [lib/json_logic/operations/](./lib/json_logic/operations/).


## Coding style

- **Follow [§ Security](./README.md#security)**.
- **Follow [§ JsonLogic Semantic](./README.md#jsonlogic-semantic)**.
- Prefer small, composable code with real examples.

## PR checklist

- [ ] Tests or examples included (when applicable).
- [ ] Compliance suite passes (see **[§ Compliance and tests](./README.md#compliance-and-tests)**).
- [ ] **[README](./README.md)** and related docs updated if user‑facing behavior changed.
- [ ] Version bumped in [Gem Version File](./lib/json_logic/version.rb).
- [ ] **[CHANGELOG](./CHANGELOG.md)** updated.

## Versioning

We use **[Semantic Versioning](https://semver.org/)**.
