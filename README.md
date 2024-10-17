[![CKAN Docker Stack Test](https://github.com/vuhitra-io/ckan-docker/actions/workflows/test.yml/badge.svg)](https://github.com/vuhitra-io/ckan-docker/actions/workflows/test.yml)

# My CKAN docker stack for quick work

Check original readme [here](https://github.com/ckan/ckan-docker/blob/master/README.md)

- Additional ckan_ini parameters in __ckan_ini_configs__.txt
- Additional commands in __commands__.txt
- plugins in __project_env__

## How to use:
First clone [ckan-docker-base](https://github.com/vuhitra-io/ckan-docker-base),
- make build in base,
- make build in dev

Then CD to ckan-docker;
- make purge (to create from scratch)
- make rebuild (or)

To include extensions, add them as submodule in ckan/extensions or clone them in it.
