## Description

A base HTML, CSS and JavaScript project.

## Initialisation

In the Makefile edit PROJECT_NAME and INSTALL_DIR, then run:

    make init

The project assumes that the installation directory will be owned by a user with the same name as the project name, and that the user running 'make install' can sudo to that user. If the installation directory is owned by a different user, or if sudo is not needed, edit or delete this line in the Makefile:

    SUDO ?= $(PROJECT_NAME)

## tmux

Launch the project tmux session

    ./project.tmux

## Build

Development environment

    make all

Staging environment (minified JS and CSS)

    make all ENVIRONMENT=staging

Production environment (minified JS and CSS)

    make all ENVIRONMENT=production

## Install

    make install

## Clean

    make clean 

## File watching

Watch for file changes and automatically recompile and install (make install)

    ./watch.sh

## Dependencies

GNU Make\
cwebp\
dart-sass (alternatively, the NPM sass package can be installed)\
inotifywait (for file watching)

## License

MIT
