# upstreams/

This directory is populated automatically by `make bootstrap` using the definitions in `config/upstreams.list`. Each subdirectory is a full clone of an upstream project (PeTTa, MORK, PathMap, etc.).

Guidelines:

- Treat these as vendor directories: only commit changes here when you intentionally vendor a patch. Otherwise, contribute upstream and refresh via `make bootstrap`.
- Do not add your own code directly under `upstreams/`; use `local/src` (once created) or another repo-local path.
- Each upstream repository maintains its own README and build instructions. Refer to them when hacking in that submodule.

If you need to pin or refresh upstream SHAs, use `make lock`, `make update`, or `make unlock` rather than editing `config/upstreams.list` by hand.
