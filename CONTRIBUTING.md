
# Contribution Guide

**Contributions are very welcome!** Whether it's a small typo fix, a new operator, a better example, or a larger refactor — your help makes this gem better. If you're unsure where to start, open an issue and we can figure it out together.

## Quick links (README)
- **Install & Quick start:** see [README → Install](./README.md#install) and [Quick start](./README.md#quick-start)
- **How the engine works (value vs lazy/enumerable):** see [README → How](./README.md#how)
- **Supported operations:** see [README → Supported Operations (Built‑in)](./README.md#supported-operations-built-in)
- **Adding operations:** see [README → Adding Operations](./README.md#adding-operations)
- **JsonLogic semantics (comparisons & truthiness):** see [README → JsonLogic Semantic](./README.md#jsonlogic-semantic)
- **Compliance & tests:** see [README → Compliance and tests](./README.md#compliance-and-tests)

## Running tests & compliance

Use the **same commands** as in the README’s [Compliance and tests](./README.md#compliance-and-tests) section.

## How to contribute

1. Fork the repo and create a branch from `main`.
2. Make your change (code, docs, or tests).
3. Include examples for new operators or pretty mappings.
4. Update `README.md` and docs if public behavior changes.
5. Run your tests.
6. Open a Pull Request and describe:
   - What changed and why
   - Any breaking impacts
   - Before/after output if applicable

### Adding an operator

Operator creation and registration are described in the README’s [Adding Operations](./README.md#adding-operations) section.

Auto-registration is enabled for classes under `lib/json_logic/operations/`.

## Coding style

- **Follow [README → Security](./README.md#security)**
- Prefer simple, composable code.
- Match the semantics from the official docs:
  - Operations: <https://jsonlogic.com/operations.html>
  - Truthiness: <https://jsonlogic.com/truthy.html>
- When relevant, use `using JsonLogic::Semantics` to align comparisons/truthiness with JsonLogic.

## PR checklist

- [ ] Tests or examples included (when applicable)
- [ ] Compliance suite passes (see [README → Compliance and tests](./README.md#compliance-and-tests))
- [ ] README/docs updated if user‑facing behavior changed

## Versioning

We use **Semantic Versioning** (MAJOR.MINOR.PATCH).

- Bump `lib/json_logic/version.rb` using SemVer.
- Update `CHANGELOG.md`.
