# SKSE-Shared

A collection of reusable C++ source and header files shared across multiple projects.

This repository is **not** intended to be built independently. Instead, it is embedded into other projects using **Git subtree**.

## Integration

To use the repository, add it to your `src` directly, effectively treating it as part of your own code base

```
subtree add --prefix=src/shared https://github.com/KrisV-777/SKSE-Shared.git master
```

Changes can be pulled from upstream with

```
git subtree pull --prefix=src/shared https://github.com/KrisV-777/SKSE-Shared.git master --squash
```

Pull Requests are, of course, accepted.
