
# Contributing to json-logic-rb

**Contributions are very welcome!**  Whether it's a small typo fix, a new operator, a better example, or a larger refactor — your help makes this gem better. If you're unsure where to start, open an issue and we can figure it out together.


## Quick links (README)
- **Install & Quick start:** see [README → Install](./README.md#install) and [Quick start](./README.md#quick-start)
- **How Engine works (value vs lazy/enumerable):** see [README → How](./README.md#how)
- **Supported operations:** see [README → Supported Built-in Operations](./README.md#supported-built-in-operations)
- **Public Interface:** see [README → Public Interface](./README.md#public-interface)
- **Compliance & tests:** see [README → Compliance & tests](./README.md#compliance--tests)



## Running tests & compliance

Use the **same commands** as in the README’s [Compliance & tests](./README.md#compliance--tests) section.



## Adding an operator

Operator adding and registration are described in the README’s [Extending (add your own operator)](./README.md#extending-add-your-own-operator) section.

Auto-registration is enabled in `lib/json_logic/operations/`


## Coding style

Please follow the conventions listed in the README and keep operators **pure** (no IO/network/shell).
Match the semantics from the official docs:
- Operations: https://jsonlogic.com/operations.html
- Truthiness: https://jsonlogic.com/truthy.html

---

## PR checklist

- [ ] Tests or examples included (when applicable)
- [ ] Compliance suite passes (see [README](./README.md#compliance--tests))
- [ ] README updated if user-facing behavior changed


## Versioning

We use **Semantic Versioning** (MAJOR.MINOR.PATCH).
