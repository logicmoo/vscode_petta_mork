# Changelog

All notable changes to this workspace will be documented here.

## [Unreleased]

### Added
- `scripts/link_toolchains.sh` and README instructions for linking host/container Rust toolchains and SWI-Prolog packs.
- `make update` helper that bootstraps upstreams and re-locks pinned SHAs in one step.
- `scripts/unlock_repos.sh` and `make unlock` to reset `config/upstreams.list` back to AUTO.

### Changed
- README/AGENTS instructions now emphasize that `make lock` is for release maintainers; contributors should skip it.
- Setup guide no longer references the initial unzip of the template archive; it assumes the repo is already cloned.
