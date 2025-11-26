# config/

This directory holds configuration inputs for the workspace:

- `upstreams.list` is the source of truth for every external repository cloned into `../upstreams/`. Each line follows `name url branch pin`, where the pin is usually `AUTO` or `TIP`. The automation scripts (`make bootstrap`, `make lock`, `make unlock`) read and modify this file.
- Additional config files that influence scripts or containers should live here so they can be versioned and discovered easily.

When adding a new upstream, edit `upstreams.list` and run `make bootstrap` to sync it. Remember to use `make lock` / `make unlock` only if you are a release maintainer.
