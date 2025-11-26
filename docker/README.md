# docker/

Container plumbing for the development environment:

- [`Dockerfile`](Dockerfile) builds the `petta-dev` image (Ubuntu 22.04 with SWI-Prolog, Python, build-essential, etc.). `make build` and `make up` rely on this file.
- Any auxiliary scripts or assets needed during `docker build` belong here.

If you need to add packages or tweak the user-creation logic, edit the Dockerfile in this directory and rebuild with `make build`. Keep the image lean; host-specific customizations should happen via scripts rather than baking credentials into the image.
