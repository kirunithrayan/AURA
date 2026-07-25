# Contributing to AURA

First off, thank you for considering contributing to AURA! It's people like you that make AURA such a powerful open-source tool.

## Repository Workflow

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally.
3. **Branch** off of `main` for your work.
4. **Commit** your changes following our commit conventions.
5. **Push** your branch to your fork.
6. **Submit** a Pull Request against the upstream `main` branch.

## Branch Naming Convention

Please prefix your branch names to clearly communicate the purpose of your work:

- `feature/` - For new features (e.g., `feature/semantic-search`)
- `bugfix/` - For bug fixes (e.g., `bugfix/sqlite-crash`)
- `hotfix/` - For critical production fixes (e.g., `hotfix/memory-leak`)
- `refactor/` - For architectural or code organization changes (e.g., `refactor/extract-parser-interface`)

## Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/). This ensures our changelogs can be generated automatically.

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to the build process or auxiliary tools/libraries

Example: `feat: implement markdown parser for metadata extraction`

## Coding Standards

- **Null Safety:** Ensure all code adheres to strict sound null safety.
- **State Management:** Use `flutter_riverpod`. Do not use `setState` unless strictly necessary for ephemeral, local UI animations.
- **Dependency Injection:** Use `get_it` exclusively for providing Repositories, Services, and UseCases.
- **Testing:** New features should include relevant unit tests in the `test/` folder.

## Folder Conventions

AURA adheres strictly to **Clean Architecture**. When adding new features, place them in `lib/features/<feature_name>/` and follow this structure:

```
feature_name/
  ├── presentation/   # UI, Widgets, ViewModels (Riverpod providers)
  ├── domain/         # Entities, UseCases, Repository Interfaces
  └── data/           # Repository Implementations, Models, DataSources
```

**Never** import a file from `data/` or `presentation/` into the `domain/` layer.

## Pull Request Checklist

Before submitting your PR, please ensure you have completed the following:

- [ ] My code follows the code style and coding standards of this project.
- [ ] I have verified that my code conforms to the Clean Architecture layer constraints.
- [ ] I have updated the documentation accordingly (if applicable).
- [ ] I have run `dart format .` and `dart analyze` and resolved all warnings.
- [ ] My branch name follows the conventions outlined above.
- [ ] My commit messages follow the Conventional Commits specification.
