# Changelog

## [Unreleased]

- TECH-253: Adopt production-tested patterns from Objective Zero
  - Refactor BLoC singletons to use nullable instance with async reset/dispose
  - Replace `base class Api` with `ApiMixin` mixin pattern
  - Add shared `Logger` mixin to replace per-class Logger boilerplate
  - Migrate from mockito (codegen) to mocktail (no codegen)
  - Add shared mock classes, fabricators, and test stubs
  - Fix BLoC dispose leaks (cancel subscriptions, close subjects)
  - Handle Firebase duplicate-app initialization on iOS
  - Add `Json` type alias and use named parameters in `ApiError`
  - Remove build_runner dependency
